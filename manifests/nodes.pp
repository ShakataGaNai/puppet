node default {
	include base

	delete_lines{ removecfengine:
		file    => "/etc/motd",
		pattern => "^.*CFEngine.*$" }

	append_if_no_such_line{ motd:
		file => "/etc/motd",
		line => "Configured with Puppet!"}

}

node web-default inherits default {
	include apache

}

node webserver1 inherits web-default {

}