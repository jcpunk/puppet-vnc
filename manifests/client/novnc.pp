# @summary Setup a webserver running the NoVNC interface
#
# @param manage_packages
#   Should this class manage the packages
# @param packages
#   List of packages to install
# @param packages_ensure
#   Ensure state of the vnc server packages
class vnc::client::novnc (
  Boolean $manage_packages,
  Array $packages,
  String $packages_ensure,
) {
  contain 'vnc::client::novnc::install'
  contain 'vnc::client::novnc::config'
  contain 'vnc::client::novnc::service'

  Class['vnc::client::novnc::install'] -> Class['vnc::client::novnc::config'] ~> Class['vnc::client::novnc::service']
  Class['vnc::client::novnc::install'] ~> Class['vnc::client::novnc::service']
}
