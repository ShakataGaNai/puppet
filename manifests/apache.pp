### Usage examples ###
#
# apache::vhost{ "mycompany.com":
#  aliases => ["apache.mycompany.com","www.mycompany.com"],
#  order => "500"
# }
#
# apache::remove_vhost{ "badsite.mycompany.com":
#  order => "500"
# }
#
# include apache
#
### End examples ###

define apache::vhost ($aliases, $order = "500" ) {

	# Create the directory to keep the files
	file {  "/var/websites/$name":
		ensure => "directory"
	}

	# Create the apache config from template, restart service
	file { "apache-vhost-$name":
		path    => "/etc/apache2/sites-enabled/${order}-${name}",
			content => template("apache/vhost.erb"),
			notify  => Service[apache2];
		}

} # define apache::vhost

define apache::remove_vhost ($order = "500" ){

	#Remove the file, restart the service
	file { "apache-vhost-$name":
		path    => "/etc/apache2/sites-enabled/${order}-${name}",
		ensure => absent,
		notify  => Service[apache2];
	}

} #define apache::remove_vhost

#define apache::module ( $ensure = 'present', $require = 'apache2' ) {
#$apache2_mods = "/etc/apache2/mods"
#	case $ensure {
#		present' : {
#			exec { "/usr/sbin/a2enmod $name":
#				unless => "/bin/readlink -e ${apache2_mods}-enabled/${name}.load",
#				notify => Exec["force-reload-apache2"],
#				require => Package[$require],
#			}
#		}
#		'absent': {
#			exec { "/usr/sbin/a2dismod $name":
#				onlyif => "/bin/readlink -e ${apache2_mods}-enabled/${name}.load",
#				notify => Exec["force-reload-apache2"],
#				require => Package["apache2"],
#			}
#		}
#	default: { err ( "Unknown ensure value: '$ensure'" ) }
#	}
#}

class apache {

	$packages = [ "apache2", "php5", "php-pear"]

	if $lsbdistid == "Ubuntu" {
		package { $packages:
			ensure => latest;
		}
	}


	#Make sure the service is running and starts on boot
	service { 'apache2':
		name => "apache2",
		enable => true,
		ensure => running;
	}

	#All vhosts will be in here, make sure the base level exists
	file { "/var/websites/":
		ensure => "directory"
	}

	exec { "/usr/sbin/a2enmod rewrite" :
		unless => "/bin/readlink -e /etc/apache2/mods-enabled/rewrite.load",
		notify => Service[apache2]
	}

	file { "/etc/apache2/sites-enabled/000-default":
		ensure => present,
		source => "puppet:///files/apache/site-default",
		notify => Service[apache2];
	}

	file { "/etc/apache2/apache2.conf":
		ensure => present,
		source => "puppet:///files/apache/apache2.conf",
		notify => Service[apache2];
	}

	file { "/etc/apache2/httpd.conf":
		ensure => present,
		source => "puppet:///files/apache/httpd.conf",
		notify => Service[apache2];
	}

	file { "ports.conf":
		path => "/etc/apache2/ports.conf",
		ensure => present,
		content => template("apache/ports.conf.erb"),
		notify => Service[apache2];
	}

} #class apache
