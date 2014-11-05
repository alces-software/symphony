################################################################################
##
## Alces Symphony Management Platform  - Puppet configuration files
## Copyright (c) 2008-2014 Alces Software Ltd
##
################################################################################
class symphonymonitor::ganglia (
  $install_ganglia,
  $masterdns,
  $clientname,
  $role,
)
{
  if $install_ganglia {
    class{ 'ganglia::gmond':
      cluster_name       => 'core',
      #cluster_owner      => '',
      #cluster_url        => 'www.example.org',
      udp_recv_channel   => [ { port => 8649, ttl => 1 } ],
      udp_send_channel   => [ { port => 8649 , mcast_join => "$masterdns"} ],
      tcp_accept_channel => [ { port => 8659 } ],
    }
    if $role == 'master' {
      $clusters = [
        {
          name     => "core",
          address  => ['symphony-monitor:8659'],
        },
      ]

      class{ 'ganglia::gmetad':
        clusters => $clusters,
        gridname => $clientname,
      }
      class{ 'ganglia::web':
        ganglia_ip => '127.0.0.1',
        ganglia_port => 8652,
      }
      file { '/etc/httpd/conf.d/ganglia.conf':
        ensure=>present,
        content=>template('symphonymonitor/ganglia.conf.el7'),
        owner=>'root',
        group=>'root',
        mode=>0644
      }
    } 
  }
}
