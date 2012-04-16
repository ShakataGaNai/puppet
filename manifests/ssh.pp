class ssh {
	package { "openssh-client":
		ensure => latest
	}

	package { "openssh-server":
		ensure => latest;
	}

	service { "ssh":
		ensure => running,
		subscribe => File["/etc/ssh/sshd_config"];
	}

	file { "/etc/ssh/sshd_config":
		owner => root,
		group => root,
		mode => 0644,
		source => "puppet:///files/ssh/sshd_config";
	}
}
