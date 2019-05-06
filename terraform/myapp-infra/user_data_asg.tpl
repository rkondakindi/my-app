#!/bin/bash
yum update -y
yum install git wget -y

# Install chefdk
cd /tmp
wget https://packages.chef.io/files/stable/chefdk/3.9.0/el/7/chefdk-3.9.0-1.el7.x86_64.rpm
yum localinstall /tmp/chefdk-3.9.0-1.el7.x86_64.rpm -y

# Download chef coookbook to host
cd /tmp/
git clone https://github.com/rkondakindi/my-app
cd /tmp/my-app/chef/
chef-solo -c /tmp/my-app/chef/solo.rb -j /tmp/my-app/chef/roles/web-app.json
