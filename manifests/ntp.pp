class ntp::server {
	file { "/etc/ntp.conf":
		owner => root,
		group => root,
		mode => 0644,
		source => "puppet:///files/ntp/ntp.server";
	}
}

class ntp::client {
	file { "/etc/ntp.conf":
		owner => root,
		group => root,
		mode => 0644,
		source => "puppet:///files/ntp/ntp.client";
	}
}

class ntp {

        $packages = [ "ntp", "ntpdate" ]

	if $lsbdistid == "Ubuntu" {
		package { $packages:
			ensure => latest;
		}
		service { ntp:
			ensure => running,
			subscribe => [ File["/etc/ntp.conf"] ];
		}
	}

	include ntp::client
}

