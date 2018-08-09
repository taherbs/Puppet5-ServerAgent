#!/bin/sh
# Run on VM to bootstrap script to install Puppet agent
# This script will only run on Ubuntu16 boxes

# Source data from the source script
echo "##### $PUPPET_CONF"

if [ -d "$PUPPET_CONF" ]
then
    echo "Puppet Agent is already installed. Moving on..."
else
    # Install Puppet Agent
    wget -cO - ${PUPPET_DEB} > /tmp/puppet.deb && \
    sudo dpkg -i /tmp/puppet.deb && \
    sudo apt-get update -yq && sudo apt-get upgrade -yq && \
    sudo apt-get install -yq puppet-agent
    # If puppet config Dir is received
    if [ -d "$PUPPET_CONF" ]
    then
      # create symbolik links for the puppet binaries - note that this is a hack for DEV env in prod we should update the PATH variable
      ln -s ${PUPPET_BIN}/* /bin/
      # Update the puppet agent config
      echo "" && echo "[agent]\nserver=${SERVER_NODE_HOSTNAME}" | sudo tee --append "${PUPPET_CONF}/puppet/puppet.conf" 2> /dev/null
      # Start puppet agent and ensure it is enabled
      sudo ${PUPPET_BIN}/puppet resource service puppet ensure=running &
      sudo ${PUPPET_BIN}/puppet resource service puppet enable=true &
    else
      echo "Something went wrong when installing the puppet-agent package" 1>&2
    fi
    # Configure /etc/hosts
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet SERVER and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "${SERVER_NODE_IP}  ${SERVER_NODE_HOSTNAME}" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "${AGENT_NODE_IP}  ${AGENT_NODE_HOSTNAME}" | sudo tee --append /etc/hosts 2> /dev/null
fi