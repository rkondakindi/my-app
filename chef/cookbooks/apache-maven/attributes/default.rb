#
# Cookbook:: apache-maven
# attributes:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

default['apache-maven']['java_home'] = '/usr/java/latest'
default['apache-maven']['maven-version'] = '3.6.1'
default['apache-maven']['maven-source'] = "apache-maven-#{node['apache-maven']['maven-version']}-bin.tar.gz"
default['apache-maven']['maven-url'] = "http://apache.spinellicreations.com/maven/maven-3/#{node['apache-maven']['maven-version']}/binaries/#{node['apache-maven']['maven-source']}"
