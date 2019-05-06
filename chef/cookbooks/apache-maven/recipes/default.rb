#
# Cookbook:: apache-maven
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

# Install Oracle JDK
# NOTE: Oracle Stopped downloading without login. So, you can keep binaries in your artifactories and
# use remote_file resource to download file to install JDK.
cookbook_file ::File.join(Chef::Config[:file_cache_path], 'jdk-8u201-linux-x64.rpm') do
  source 'jdk-8u201-linux-x64.rpm'
  mode 0644
end

# Install JDK
package 'jdk1.8' do
  source ::File.join(Chef::Config[:file_cache_path], 'jdk-8u201-linux-x64.rpm')
  action :install
end

# Set JAVA_HOME
template '/etc/profile.d/java.sh' do
  source 'java.sh.erb'
  mode '0755'
end

execute 'run-java' do
  command 'sh /etc/profile.d/java.sh'
  only_if { `echo $JAVA_HOME` == '' }
end

# Maven Download and Installation
remote_file ::File.join(Chef::Config[:file_cache_path], node['apache-maven']['maven-source']) do
  source node['apache-maven']['maven-url']
  owner 'root'
  group 'root'
  mode 0644
end

bash 'install-maven' do
  cwd '/opt'
  code <<-EOH
    tar -xzf #{::File.join(Chef::Config[:file_cache_path], node['apache-maven']['maven-source'])} -C /opt
    EOH
  not_if { File.exist?("/opt/apache-maven-#{node['apache-maven']['maven-version']}") }
end

# Set Maven
template '/etc/profile.d/maven.sh' do
  source 'maven.sh.erb'
  owner 'root'
  group 'root'
  mode 0755
end

execute 'maven-env' do
  command '. /etc/profile.d/maven.sh'
  only_if "echo $PATH | grep apache-maven"
end
