#!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker azureuser
sudo systemctl enable docker
sudo systemctl start docker
sudo chmod 666 /var/run/docker.sock
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt-get update
# Download and extract
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux

# Move AzCopy
sudo rm -f /usr/bin/azcopy
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy

# Clean the kitchen
rm -f downloadazcopy-v10-linux
rm -rf ./azcopy_linux_amd64_*/
# Commands to install the self-hosted agent
curl -o vsts-agent-linux-x64.tar.gz https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-linux-x64-3.234.0.tar.gz
mkdir myagent
tar zxvf vsts-agent-linux-x64.tar.gz -C myagent
chmod -R 777 myagent
# Configuration of the self-hosted agent
cd myagent
./config.sh --unattended --url https://dev.azure.com/ricassky12/ --auth pat --token yumksxr4gbitbrlmy33lze55jltl22vm45yaro3uahhilcjvcmxa --pool vmagent --agent agentvm --acceptTeeEula
# Start the agent service
sudo ./run.sh install
sudo ./run.sh start
exit 0