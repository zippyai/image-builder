#!/bin/bash

function install_docker() {
    echo '>>>> Installing Docker'

    curl -fsSL get.docker.com -o get-docker.sh
    sh get-docker.sh
    # Devicemapper files are huge if got created - we don't use device mapper anyway
    rm -rf /var/lib/docker/devicemapper/devicemapper/data
    rm -rf /var/lib/docker/devicemapper/devicemapper/metadata

    echo 'env container=yes' >> /etc/init/docker.conf

    # Don't start Docker by default
    echo manual >> /etc/init/docker.conf
}

function install_circleci_docker() {
    echo '>>> Install CircleCI Docker fork that runs on user namespaces'

    # Install LXC and btrfs-tools
    apt-get -y install lxc btrfs-tools

    # DNS forwarding doesn't work without this line which causes container unable to resolve DNS
    sed -i 's|10.0.3|10.0.4|g' /etc/default/lxc-net

    # Divert plain docker
    sudo dpkg-divert --add --rename --divert /usr/bin/docker.plain /usr/bin/docker

    # Replace with CircleCI's patched docker
    sudo curl -L -o /usr/bin/docker.circleci 'https://s3.amazonaws.com/circle-downloads/docker-1.9.1-circleci'
    sudo chmod 0755 /usr/bin/docker.circleci

    # --userland-proxy=false: Docker's userland proxy is broken. Don't use it.
    echo 'DOCKER_OPTS="-s btrfs -e lxc -D --userland-proxy=false"' > /etc/default/docker

    sudo ln -s /usr/bin/docker.circleci /usr/bin/docker
}

function install_docker_compose() {
    echo '>>>> Installing Docker compose'

    curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}
