# == Class puppet_agent::params
#
# This class is meant to be called from puppet_agent
# It sets variables according to platform.
#
class puppet_agent::params {
  # Which services should be started after the upgrade process?
  if ($facts['os']['family'] == 'Solaris' and $facts['os']['release']['major'] == '11') {
    # Solaris 11 is a special case; it uses a custom script.
    $service_names = []
  } else {
    $service_names = ['puppet']
  }
  if $facts['os']['family'] == 'windows' {
    $local_puppet_dir = windows_native_path("${::puppet_agent_appdata}/Puppetlabs")
    $local_packages_dir = windows_native_path("${local_puppet_dir}/packages")

    $confdir = $::puppet_confdir

    $puppetdirs = [regsubst($confdir,'\/etc\/','/code/')]
    $path_separator = ';'

    $user  = 'S-1-5-32-544'
    $group = 'S-1-5-32-544'
  } else {
    $local_puppet_dir = '/opt/puppetlabs'
    $local_packages_dir = "${local_puppet_dir}/packages"

    $confdir = '/etc/puppetlabs/puppet'

    # A list of dirs that need to be created. Mainly done this way because
    # Windows requires more directories to exist for confdir.
    $puppetdirs = ['/etc/puppetlabs', $confdir]

    $path_separator = ':'

    $user  = 0
    $group = 0
  }
  $ssldir = "${confdir}/ssl"
  $config = "${confdir}/puppet.conf"

  # To determine if this is a PE installation or not, we check if the `pe_anchor` resource type exists
  # it's provided by the puppet_enterprise module
  $_is_pe = defined('pe_anchor')
  if $_is_pe {
    # Calculate the default collection
    $_pe_version = pe_build_version()
    # Not PE or pe_version < 2018.1.3, use PC1
    if ($_pe_version == undef or versioncmp($_pe_version, '2018.1.3') < 0) {
      $collection = 'PC1'
    }
    # 2018.1.3 <= pe_version < 2018.2, use puppet5
    elsif versioncmp($_pe_version, '2018.2') < 0 {
      $collection = 'puppet5'
    }
    # 2018.2 <= pe_version < 2021.0 use puppet6
    elsif versioncmp($_pe_version, '2021.0') < 0 {
      $collection = 'puppet6'
    }
    # pe_version >= 2021.0, use puppet7
    elsif versioncmp($_pe_version, '2023.3') < 0 {
      $collection = 'puppet7'
    }
    # pe_version >= 2023.3, use puppet8
    else {
      $collection = 'puppet8'
    }
  } else {
    $_pe_version = undef
    $pe_repo_dir = undef
    $collection = 'PC1'
  }
}
