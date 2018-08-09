# This is a test site.pp file
node default {
# Test message
  notify { "Debug output on ${hostname} node.": }

  include ntp, git
}

node 'agentnode01' {
# Test message
  notify { "Debug output on ${hostname} agent node.": }

  include ntp, docker, fig
  package { 'git':
    ensure => 'absent',
  }
}
