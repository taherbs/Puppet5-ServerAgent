#!/bin/sh
# Run on VM to bootstrap script to install Puppet Server server 
# This script will only run on Ubuntu16 boxes

# Source data from the source script
echo "##### $PUPPET_CONF"

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Server is already installed. Exiting..."
else
    # Install Puppet server
    wget -cO - ${PUPPET_DEB} > /tmp/puppet.deb && \
    sudo dpkg -i /tmp/puppet.deb && \
    sudo apt-get update -yq && sudo apt-get upgrade -yq && \
    sudo apt-get -yq install puppetserver
    # If puppet config Dir is received
    if [ -d "$PUPPET_CONF" ]
    then
		# create symbolik links for the puppet binaries - note that this is a hack for DEV Env
		# update the PATH env variable instead for PROD Env
		cp -s ${PUPPET_BIN}/* /bin/
		# update puppet config
		sed -i -e 's/JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"/JAVA_ARGS="-Xms1g -Xmx1g -XX:MaxPermSize=256m"/' /etc/default/puppetserver
		# Autosign certificates coming from agentnodes 
		echo "autosign = true" | sudo tee --append "${PUPPET_CONF}/puppet/puppet.conf" 2> /dev/null
		# restart the puppet service
		sudo service puppetserver restart
		# Enable Puppet Server so that it starts when your server boots
		sudo ${PUPPET_BIN}/puppet resource service puppetserver ensure=running
		sudo ${PUPPET_BIN}/puppet resource service puppetserver enable=true
		
		# Install some initial puppet modules on Puppet server 
		# FOR TESTING PORPOSE
		sudo puppet module install puppetlabs-ntp
		sudo puppet module install garethr-docker
		sudo puppet module install puppetlabs-git
		sudo puppet module install puppetlabs-vcsrepo
		sudo puppet module install garystafford-fig
		ln -s /vagrant/puppet-manifest/testsite.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
    else
		echo "Something went wrong when installing the puppetserver package" 1>&2
    fi
    # Configure /etc/hosts
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Server and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "${SERVER_NODE_IP}  ${SERVER_NODE_HOSTNAME}" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "${AGENT_NODE_IP}  ${AGENT_NODE_HOSTNAME}" | sudo tee --append /etc/hosts 2> /dev/null
fi