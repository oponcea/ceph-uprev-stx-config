#
# puppet manifest for controller hosts
#

Exec {
  timeout => 600,
  path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin'
}

include ::firewall

include ::platform::config
include ::platform::users
include ::platform::sysctl::controller
include ::platform::filesystem::controller
include ::platform::firewall::oam
include ::platform::dhclient
include ::platform::partitions
include ::platform::lvm::controller
include ::platform::network
include ::platform::drbd
include ::platform::exports
include ::platform::dns
include ::platform::ldap::server
include ::platform::ldap::client
include ::platform::password
include ::platform::ntp::server
include ::platform::ptp
include ::platform::lldp
include ::platform::amqp::rabbitmq
include ::platform::postgresql::server
include ::platform::haproxy::server
include ::platform::grub
include ::platform::etcd
include ::platform::docker
include ::platform::dockerdistribution
include ::platform::kubernetes::master
include ::platform::helm

include ::platform::patching
include ::platform::patching::api

include ::platform::remotelogging
include ::platform::remotelogging::proxy

include ::platform::sysinv
include ::platform::sysinv::api
include ::platform::sysinv::conductor

include ::platform::mtce
include ::platform::mtce::agent

include ::platform::memcached

include ::platform::nfv
include ::platform::nfv::api

include ::platform::ceph
include ::platform::ceph::monitor
include ::platform::ceph::storage
include ::platform::ceph::rgw

include ::platform::influxdb
include ::platform::influxdb::logrotate
include ::platform::collectd

include ::platform::fm
include ::platform::fm::api

include ::platform::multipath
include ::platform::client
include ::openstack::client
include ::openstack::keystone
include ::openstack::keystone::api

include ::openstack::glance
include ::openstack::glance::api

include ::openstack::cinder
include ::openstack::cinder::api

include ::openstack::neutron
include ::openstack::neutron::api
include ::openstack::neutron::server

include ::openstack::nova
include ::openstack::nova::api
include ::openstack::nova::network
include ::openstack::nova::controller
include ::openstack::nova::placement

include ::openstack::gnocchi
include ::openstack::gnocchi::api
include ::openstack::gnocchi::metricd

include ::openstack::ceilometer
include ::openstack::ceilometer::agent::notification
include ::openstack::ceilometer::polling

include ::openstack::aodh
include ::openstack::aodh::api

include ::openstack::panko
include ::openstack::panko::api

include ::openstack::heat
include ::openstack::heat::api

include ::openstack::horizon

include ::openstack::murano
include ::openstack::murano::api

include ::openstack::magnum
include ::openstack::magnum::api

include ::openstack::ironic
include ::openstack::ironic::api

include ::platform::dcmanager
include ::platform::dcmanager::manager

include ::platform::dcorch
include ::platform::dcorch::engine
include ::platform::dcorch::api_proxy
include ::platform::dcmanager::api

include ::platform::dcorch::snmp

include ::platform::smapi

include ::openstack::swift
include ::openstack::swift::api

include ::openstack::barbican
include ::openstack::barbican::api

include ::platform::sm

class { '::platform::config::controller::post':
  stage => post,
}

hiera_include('classes')
