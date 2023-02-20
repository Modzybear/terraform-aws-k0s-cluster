#!/bin/bash

# AWS SSM

sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

sudo systemctl status amazon-ssm-agent

# Install k0s

curl -sSLf https://get.k0s.sh | sudo K0S_VERSION=${k0s_version} sh
mv /usr/local/bin/k0s /usr/bin/

mkdir -p /etc/k0s
k0s config create > /etc/k0s/k0s.yaml

sudo k0s install controller -c /etc/k0s/k0s.yaml --enable-worker --no-taints

sudo k0s start

sleep 15

# Cronjob to log into AWS ECR
# https://stackoverflow.com/a/53852814

cat > /etc/k0s/ecr-creds.sh << 'EOF'
TOKEN=`aws ecr --region=${region} get-authorization-token --output text \
    --query authorizationData[].authorizationToken | base64 -d | cut -d: -f2`

#
#  Create or replace registry secret
#

k0s kubectl delete secret --ignore-not-found ${ecr_secret_name}
k0s kubectl create secret docker-registry ${ecr_secret_name} \
    --docker-server=https://${aws_account}.dkr.ecr.${region}.amazonaws.com \
    --docker-username=AWS \
    --docker-password="$${TOKEN}" \
    --docker-email="${docker_email}"
EOF

chmod +x /etc/k0s/ecr-creds.sh
./etc/k0s/ecr-creds.sh

crontab<<EOF
$(crontab -l)
0 */12 * * * /etc/k0s/ecr-creds.sh
EOF
