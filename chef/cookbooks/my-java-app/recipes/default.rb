#
# Cookbook:: my-java-app
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# Include Maven Recipe to install and configure maven.
include_recipe 'apache-maven::default'

# Install git
package 'git' do
  action :install
end

# NOTE: spring boot application will use port:8080 by default.
# You can change the port by creating application.properties with below content
# server.port = 9090
# spring.application.name = my-java-app

# Build hello-world springboot package
bash 'build maven' do
  cwd '/opt'
  code <<-EOH
    . /etc/profile.d/maven.sh
    rm -rf hello-world-spring-boot/
    git clone #{node['my-java-app']['repo']}
    cd hello-world-spring-boot/
    mvn clean --quiet
    mvn package --quiet
  EOH
  not_if { File.exist?('/opt/hello-world-spring-boot/target/myproject-0.0.1-SNAPSHOT.jar') && File.exist?('/opt/hello-world-spring-boot/') }
end

template '/etc/systemd/system/my-java-app.service' do
  source 'my-java-app.service.erb'
  owner 'root'
  group 'root'
  mode 0755
end

service 'my-java-app' do
  action [:enable, :start]
end
