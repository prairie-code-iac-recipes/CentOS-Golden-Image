#!/bin/bash -eux

# configure sudo
echo "$ssh_username        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
sed -i 's/^.*requiretty/#Defaults requiretty/' /etc/sudoers

# update all packages
yum update -y

# update certificates
curl --insecure http://curl.haxx.se/ca/cacert.pem -o /etc/pki/tls/certs/ca-bundle.crt
