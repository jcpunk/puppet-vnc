# @api private
#
# @summary Configure the VNC services
#
# @param manage_config
#   Should this class manage the config
# @param config_defaults_file
#   Your /etc/tigervnc/vncserver-config-defaults
# @param config_defaults
#   Settings to put in /etc/tigervnc/vncserver-config-defaults
# @param config_mandatory_file
#   Your /etc/tigervnc/vncserver-config-mandatory
# @param config_mandatory
#   Settings to put in /etc/tigervnc/vncserver-config-mandatory
# @param vncserver_users_file
#   Your /etc/tigervnc/vncserver.users
# @param vnc_servers
#   VNC server sessions to configure and stub out
# @param polkit_file
#   Your /etc/polkit-1/rules.d/25-puppet-vncserver.rules
# @param systemd_template_startswith
#   What does the vnc template service start with, not including the '@'
# @param systemd_template_endswith
#   What does the vnc template service end with, not including the '.'
# @param vnc_servers
#   See the server.pp documentation for structure
class vnc::server::config (
  $manage_config         = $vnc::server::manage_config,
  $config_defaults_file  = $vnc::server::config_defaults_file,
  $config_defaults       = $vnc::server::config_defaults,
  $config_mandatory_file = $vnc::server::config_mandatory_file,
  $config_mandatory      = $vnc::server::config_mandatory,
  $vncserver_users_file  = $vnc::server::vncserver_users_file,
  $polkit_file           = $vnc::server::polkit_file,

  $systemd_template_startswith = $vnc::server::systemd_template_startswith,
  $systemd_template_endswith   = $vnc::server::systemd_template_endswith,

  $vnc_servers = $vnc::server::vnc_servers
) inherits vnc::server {
  assert_private()

  if $manage_config {
    file { unique([dirname($config_defaults_file), dirname($config_mandatory_file)]):
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }

    file { $config_defaults_file:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('vnc/etc/tigervnc/config.epp', { 'settings' => $config_defaults }),
      notify  => Class['Vnc::Server::Service'],
    }

    file { $config_mandatory_file:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('vnc/etc/tigervnc/config.epp', { 'settings' => $config_mandatory }),
      notify  => Class['Vnc::Server::Service'],
    }

    file { $vncserver_users_file:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('vnc/etc/tigervnc/vncserver.users.epp', { 'vnc_servers' => $vnc_servers }),
    }

    concat { $polkit_file:
      owner => 'root',
      group => 'root',
      mode  => '0600',
    }

    concat::fragment { 'polkit_header':
      target  => $polkit_file,
      content => '/* THIS FILE IS MANAGED BY PUPPET */',
      order   => '01',
    }

    $vnc_servers.keys.sort.each |$username| {
      unless 'displaynumber' in $vnc_servers[$username] {
        fail("You must set the 'displaynumber' property for ${username}'s vnc server")
      }

      if $vnc_servers[$username]['user_can_manage'] {
        $polkit_hash = {
          'systemd_template_startswith' => $systemd_template_startswith,
          'systemd_template_endswith'   => $systemd_template_endswith,
          'username'                    => $username,
          'displaynumber'               => $vnc_servers[$username]['displaynumber'],
        }

        concat::fragment { "polkit entry for ${username} vnc service":
          target  => $polkit_file,
          order   => 20,
          content => epp('vnc/etc/polkit-1/rules.d/25-puppet-vncserver.rules.epp', $polkit_hash)
        }
      }

      exec { "create ~${username}/.vnc":
        command  => "mkdir -p $(getent passwd ${username} | cut -d: -f5)/.vnc",
        path     => ['/usr/bin', '/usr/sbin',],
        provider => 'shell',
        user     => $username,
        group    => 'users',
        unless   => "stat $(getent passwd ${username} | cut -d: -f5)/.vnc",
        onlyif   => "getent passwd ${username}",
      }
      exec { "chmod 700 ~${username}/.vnc":
        command  => "chmod 700 $(getent passwd ${username} | cut -d: -f5)/.vnc",
        path     => ['/usr/bin', '/usr/sbin',],
        provider => 'shell',
        user     => $username,
        group    => 'users',
        unless   => "stat $(getent passwd ${username} | cut -d: -f5)/.vnc --printf=%a|grep 700",
        onlyif   => "getent passwd ${username}",
      }

      exec { "create ~${username}/.vnc/config":
        command  => "echo '# see also ${config_defaults}' > $(getent passwd ${username} | cut -d: -f5)/.vnc/config",
        path     => ['/usr/bin', '/usr/sbin',],
        provider => 'shell',
        user     => $username,
        group    => 'users',
        unless   => "stat $(getent passwd ${username} | cut -d: -f5)/.vnc/config",
        onlyif   => "getent passwd ${username}",
      }
      exec { "chmod 600 ~${username}/.vnc/config":
        command  => "chmod 600 $(getent passwd ${username} | cut -d: -f5)/.vnc/config",
        path     => ['/usr/bin', '/usr/sbin',],
        provider => 'shell',
        user     => $username,
        group    => 'users',
        unless   => "stat $(getent passwd ${username} | cut -d: -f5)/.vnc/config --printf=%a|grep 600",
        onlyif   => "getent passwd ${username}",
      }

      exec { "create ~${username}/.vnc/passwd":
        command  => "head -1 /dev/urandom > $(getent passwd ${username} | cut -d: -f5)/.vnc/config",
        path     => ['/usr/bin', '/usr/sbin',],
        provider => 'shell',
        user     => $username,
        group    => 'users',
        unless   => "stat $(getent passwd ${username} | cut -d: -f5)/.vnc/config",
        onlyif   => "getent passwd ${username}",
      }
      exec { "chmod 600 ~${username}/.vnc/passwd":
        command  => "chmod 600 $(getent passwd ${username} | cut -d: -f5)/.vnc/passwd",
        path     => ['/usr/bin', '/usr/sbin',],
        provider => 'shell',
        user     => $username,
        group    => 'users',
        unless   => "stat $(getent passwd ${username} | cut -d: -f5)/.vnc/passwd --printf=%a|grep 600",
        onlyif   => "getent passwd ${username}",
      }
    }
  }
}
