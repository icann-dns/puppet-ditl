# == Class: ditl
#
class ditl (
  Tea::Puppetsource $upload_key_source  = undef,
  String            $upload_user        = undef,
  Boolean           $enabled            = true,
  Tea::Absolutepath $pcap_dir           = '/opt/pcap',
  String            $pattern            = '*.{bz2,xz}',
  Tea::Fqdn         $upload_host        = 'capture.ditl.dns-oarc.net',
  Tea::Absolutepath $upload_key_file    = '/root/.ssh/oarc_id_dsa',
  Boolean           $clean_known_hosts  = false,
) {
  $ensure = $enabled ? {
    true    => 'present',
    default => 'absent',
  }
  file {'/usr/local/bin/ditl_upload':
    ensure  => $ensure,
    mode    => '0755',
    content => template('ditl/usr/local/bin/ditl_upload.erb');
  }
  file{$upload_key_file:
    ensure => $ensure,
    mode   => '0600',
    source => $upload_key_source;
  }
  cron { 'ditl_upload':
    ensure  => $ensure,
    command => '/usr/local/bin/ditl_upload',
    user    => root,
    minute  => '*/10',
    require => File['/usr/local/bin/ditl_upload'];
  }
}
