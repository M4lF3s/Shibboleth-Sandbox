#!/usr/bin/env bash

# install necessery tools
yum install -y gcc-c++ patch \
      readline readline-devel \
      zlib zlib-devel libyaml-devel \
      libffi-devel openssl-devel make \
      bzip2 autoconf automake libtool \
      bison iconv-devel libyaml \
      rubygems ruby-devel git svn \
      ntp ntpdate ntp-doc


# add the hostname to /etc/hosts
echo 127.0.0.1 $HOSTNAME >> /etc/hosts


# enable ntpd
chkconfig ntpd on
ntpdate pool.ntp.org
systemctl start ntpd


# install pip
cd /tmp
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install requests


# install Ruby + Chef
cd /tmp
curl -O ftp://ftp.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
tar -zxvf ruby-2.3.1.tar.gz
cd ruby-2.3.1
./configure --prefix=/usr/local
make
make install
gem install chef ruby-shadow --no-ri --no-rdoc


# install chef-librarian + dependencies
mkdir /var/chef
cd /var/chef
gem install librarian-chef --no-ri --no-rdoc
librarian-chef init


echo "cookbook 'mint-apache',
  :git => 'https://github.com/mfraas64/Shibboleth-Sandbox',
  :ref => 'cookbooks'
  :path => 'cookbooks/mint-apache'
" >> Cheffile
librarian-chef install

# ceckout chef-solo
svn checkout https://github.com/mfraas64/Shibboleth-Sandbox/branches/chef-solo/chef /var/chef


# change to the chef Directory and execute chef-solo
cd /var/chef
chef-solo -c solo.rb


# Turn Off Firewall
systemctl stop firewalld
systemctl disable firewalld
