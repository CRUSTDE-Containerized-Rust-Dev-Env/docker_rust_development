#!/bin/sh

# ~/.ssh/sshadd.sh

echo "   Add often used SSH key identity to ssh-agent"
# The ssh-agent is started already on login inside the ~/.bashrc script.
# Replace the words github_com_ssh_1 and bestia_dev_ssh_1 with your file names.
# The keys are restricted only to explicit servers/hosts in the ~/.ssh/config file.
# The keys will expire in 1 hour. 
# A confirmation is requested from the user every time the added identities are used for authentication.

# add if key not yet exists for git@github.com
ssh-add -l |grep -q `ssh-keygen -lf ~/.ssh/github_com_ssh_1 | awk '{print $2}'` || ssh-add -t 1h -c ~/.ssh/github_com_ssh_1.pem

# add if key not yet exists for luciano_bestia@bestia.dev
ssh-add -l |grep -q `ssh-keygen -lf ~/.ssh/bestia_dev_ssh_1 | awk '{print $2}'` || ssh-add -t 1h -c ~/.ssh/bestia_dev_ssh_1

echo "   List public fingerprints inside ssh-agent:"
echo "   ssh-add -l"
ssh-add -l

echo " "
