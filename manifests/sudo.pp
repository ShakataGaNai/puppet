class sudo {
	file { "/etc/sudoers":
		owner => root,
		group => root,
		mode  => 440,
		source => "puppet:///files/sudo/sudoers"
	}
}
