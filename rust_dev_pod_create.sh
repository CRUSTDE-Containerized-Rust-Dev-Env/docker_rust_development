#!/usr/bin/env bash


# TODO: check if it is executed from /docker_rust_development/
# because there are stored the Host SSH keys and config file
# TODO: check if pod exists.

echo " "
echo "Bash script to create the pod 'rust_dev_pod'"
echo "This 'pod' is made of the containers 'rust_dev_squid_cnt' and 'rust_dev_vscode_cnt'"
echo "All outbound network traffic from rust_dev_vscode_cnt goes through the proxy Squid."
echo "Published inbound network ports are 8001 on 'localhost'"
echo "https://github.com/bestia-dev/docker_rust_development"

echo " "
echo "Create pod"
# in a "pod" the "publish port" is tied to the pod and not containers.

podman pod create \
-p 127.0.0.1:8001:8001/tcp \
-p 127.0.0.1:2201:2201/tcp \
--label name=rust_dev_pod \
--label version=1.0 \
--label source=github.com/bestia-dev/docker_rust_development \
--label author=github.com/bestia-dev \
--name rust_dev_pod

echo " "
echo "Create container rust_dev_squid_cnt in the pod"
# why is here --restart=always
podman create --name rust_dev_squid_cnt --pod=rust_dev_pod -ti \
docker.io/bestiadev/rust_dev_squid_img:latest

echo " "
echo "Create container rust_dev_vscode_cnt in the pod"
podman create --name rust_dev_vscode_cnt --pod=rust_dev_pod -ti \
--env http_proxy=http://localhost:3128 \
--env https_proxy=http://localhost:3128 \
--env all_proxy=http://localhost:3128  \
docker.io/bestiadev/rust_dev_vscode_img:latest

echo "copy SSH server config"
podman cp ./etc_ssh_sshd_config.conf rust_dev_vscode_cnt:/etc/ssh/sshd_config
echo "copy the directory for host keys for SSH server in rust_dev_pod"
podman cp ~/.ssh/rust_dev_pod_keys/etc/ssh/  rust_dev_vscode_cnt:/etc/ssh/
echo "copy the public key of rustdevuser"
podman cp ~/.ssh/rustdevuser_key.pub rust_dev_vscode_cnt:/home/rustdevuser/.ssh/authorized_keys

echo "podman pod start"
podman pod start rust_dev_pod
echo "user permissions"
#TODO: maybe this is not needed?
podman exec -it --user=root  rust_dev_vscode_cnt usermod -p '*' rustdevuser
podman exec -it --user=root  rust_dev_vscode_cnt usermod -aG sudo rustdevuser

echo "git global config"
podman exec -it rust_dev_vscode_cnt git config --global pull.rebase false
podman exec -it rust_dev_vscode_cnt git config --global user.email "info@bestia.dev"
podman exec -it rust_dev_vscode_cnt git config --global user.name "bestia.dev"

echo "start the SSH server"
podman exec -it --user=root  rust_dev_vscode_cnt service ssh restart

echo " "
echo " To start this 'pod' after a reboot type: "
echo "podman pod restart rust_dev_pod"
echo "podman exec -it --user=root rust_dev_vscode_cnt service ssh restart"

echo " "
echo "Open VSCode, press F1, type 'ssh' and choose 'Remote-SSH: Connect to Host...' and choose `rust_dev_pod`" 
echo " This will open a new VSCode windows attached to the container."
echo " If needed Open VSCode terminal with Ctrl+J"
echo " Inside VSCode terminal, go to the project folder. Here we will create a sample project:"
echo "cd ~/rustprojects"
echo "cargo new rust_dev_hello"
echo "cd ~/rustprojects/rust_dev_hello"

echo " "
echo " Secondly: open a new VSCode window exactly for this project/folder."
echo "code ."
echo " A new VSCode windows will open for the 'rust_dev_hello' project. You can close now all other VSCode windows."

echo " "
echo " Build and run the project in the VSCode terminal:"
echo "cargo run"

echo " "
echo " If you need ssh for git or publish_to_web, inside the VSCode terminal run the ssh-agent:"
echo "eval $(ssh-agent) "
echo "ssh-add /home/rustdevuser/.ssh/githubssh1"

