## Vagrant - Puppet5 server/agent

A Vagrant environment to deploy a puppet5 server/agent lab environment.<br />
* Server Node runs on **Ubuntu16.04**.
* Agent Node runs on **Ubuntu16.04**.

**Note:** The puppet server (servernode) is very memory greedy and it will only work properly with 4GB of memory or above.

### Usage:

Provision the VM and ssh it:

```bash
vagrant up
vagrant ssh "node_name"
```

### Configure Vagrant Nodes and Parameters

You can configure the Vagrant project nodes and params by editing the [nodes.json](./nodes.json) and the [params.json](./params.json) doles

### Useful commands: 

```bash
vagrant destroy #delete the VM, and you will lose any and all work on the instance
vagrant up      #create a VM
vagrant suspend #suspend the vm 
vagrant resume  #resume a suspended vm
```

### Test agent/server connection

```bash
# test agent/server connection, run the bollow command from the agent node
sudo puppet agent --test --noop # Dry run
sudo puppet agent --test # Normal run/Will  pull changes
```
