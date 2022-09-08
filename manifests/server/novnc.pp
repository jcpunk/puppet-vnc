# @summary Setup a webserver running the NoVNC interface
#
# @example
#   include vnc::server::novnc
class vnc::server::novnc {
  contain 'vnc::server::novnc::install'
  contain 'vnc::server::novnc::config'
  contain 'vnc::server::novnc::service'

  Class['vnc::server::novnc::install'] -> Class['vnc::server::novnc::config'] ~> Class['vnc::server::novnc::service']
}
