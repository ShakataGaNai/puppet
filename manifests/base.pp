import "sudo.pp"
import "ntp.pp"
import "ssh.pp"

class base::apt {
	file { "/etc/apt/sources.list":
		mode => 0644,
		owner => root,
		group => root,
		source => "puppet:///files/apt/sources.list";
	}

	package { apt-show-versions:
		ensure => latest;
	}
	
	package { unattended-upgrades:
		ensure => latest;
	}

	file { "/etc/apt/apt.conf.d/20auto-upgrades":
		mode => 0644,
		owner => root,
		group => root,
		source => "puppet:///files/apt/20auto-upgrades",
		require => Package[unattended-upgrades]
	}

	file { "/etc/apt/apt.conf.d/50unattended-upgrades":
		mode => 0644,
		owner => root,
		group => root,
		source => "puppet:///files/apt/50unattended-upgrades",
		require => Package[unattended-upgrades]
	}

}

class base::apt::update {
	exec { "/usr/bin/apt-get update":
		timeout => 240,
		returns => [ 0, 100 ];
	}
}

class base::puppet {
	cron { "puppet":
		command => "/usr/sbin/puppetd --onetime --no-daemonize --logdest syslog --server PUPPET.MYCOMPANY.INTERNAL > /dev/null 2>&1",
		user => "root",
		minute => fqdn_rand( 60 ),
		ensure => present,
	}

	package { [ "puppet" ]:
		ensure => latest;
	}

	file { "/etc/default/puppet":
		mode => 0644,
		owner => root,
		group => root,
		source => "puppet:///files/puppet/default.client";
	}
	
	service { 'puppet':
		name => "puppet",
		enable => false,
		ensure => stopped;
	}
}


class base::standard-packages {
	$packages = [ "screen", "wajig", "mlocate", "lynx", "curl", "snmp", "git", "subversion", "nmap", "tmux", "php5-cli", "php5-curl", "tcsh"]

	if $lsbdistid == "Ubuntu" {
		package { $packages:
			ensure => latest;
		}

#		package { [ "vi" ]:
#			ensure => absent;
#		}
	}
}

class base::resolve {
	if $realm == "c2" {
		file { "/etc/resolv.conf":
			owner => root,
			group => root,
			mode => 0644,
			source => "puppet:///files/resolve/resolve.server";
		}

	} else {
		file { "/etc/resolv.conf":
			owner => root,
			group => root,
			mode => 0644,
			source => "puppet:///files/resolve/resolve.base";
		}
	}
}



class base {
	include base::apt,
	##	base::apt::update,
		base::puppet,
		base::standard-packages,
		ssh,
		sudo,
		ntp
}
