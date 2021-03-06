#
# Copyright (c) 2018 Wind River Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#

from sysinv.common import constants
from sysinv.common import exception
from sysinv.openstack.common import log as logging
from sysinv.helm import common
from sysinv.helm import openstack

LOG = logging.getLogger(__name__)


class GnocchiHelm(openstack.OpenstackBaseHelm):
    """Class to encapsulate helm operations for the gnocchi chart"""

    CHART = constants.HELM_CHART_GNOCCHI
    SUPPORTED_NAMESPACES = [
        common.HELM_NS_OPENSTACK
    ]

    SERVICE_NAME = 'gnocchi'
    AUTH_USERS = ['gnocchi']

    def get_namespaces(self):
        return self.SUPPORTED_NAMESPACES

    def get_overrides(self, namespace=None):
        overrides = {
            common.HELM_NS_OPENSTACK: {
                'images': self._get_images_overrides(),
                'pod': self._get_pod_overrides(),
                'conf': self._get_conf_overrides(),
                'dependencies': {
                    'static': self._get_static_dependencies_overrides()
                },
                'manifests': self._get_manifests_overrides(),
                'endpoints': self._get_endpoints_overrides(),
            }
        }

        if namespace in self.SUPPORTED_NAMESPACES:
            return overrides[namespace]
        elif namespace:
            raise exception.InvalidHelmNamespace(chart=self.CHART,
                                                 namespace=namespace)
        else:
            return overrides

    def _get_images_overrides(self):
        heat_image = self._operator.chart_operators[
            constants.HELM_CHART_HEAT].docker_image
        return {
            'tags': {
                'db_init': self.docker_image,
                'db_init_indexer': self.docker_image,
                'db_sync': self.docker_image,
                'gnocchi_api': self.docker_image,
                'gnocchi_metricd': self.docker_image,
                'gnocchi_resources_cleaner': self.docker_image,
                'gnocchi_statsd': self.docker_image,
                'ks_endpoints': heat_image,
                'ks_service': heat_image,
                'ks_user': heat_image,
            }
        }

    def _get_pod_overrides(self):
        return {
            'replicas': {
                'api': self._num_controllers()
            }
        }

    def _get_static_dependencies_overrides(self):
        return {
            'db_sync': {
                'jobs': [
                    'gnocchi-storage-init',
                    'gnocchi-db-init',
                ],
                'services': [
                    {'endpoint': 'internal', 'service': 'oslo_db'}
                ]
            },
            'metricd': {
                'services': [
                    {'endpoint': 'internal', 'service': 'oslo_db'},
                    {'endpoint': 'internal', 'service': 'oslo_cache'},
                    {'endpoint': 'internal', 'service': 'metric'}
                ]
            },
            'tests': {
                'services': [
                    {'endpoint': 'internal', 'service': 'identity'},
                    {'endpoint': 'internal', 'service': 'oslo_db'},
                    {'endpoint': 'internal', 'service': 'metric'}
                ]
            }
        }

    def _get_manifests_overrides(self):
        return {
            'daemonset_statsd': False,
            'service_statsd': False,
            'job_db_init_indexer': False,
            'secret_db_indexer': False,
        }

    def _get_conf_overrides(self):
        return {
            'gnocchi': {
                'indexer': {
                    'driver': 'mariadb'
                },
                'keystone_authtoken': {
                    'interface': 'internal'
                }
            }
        }

    def _get_endpoints_overrides(self):
        return {
            'identity': {
                'auth': self._get_endpoints_identity_overrides(
                    self.SERVICE_NAME, self.AUTH_USERS),
            },
            'oslo_cache': {
                'auth': {
                    'memcached_secret_key':
                        self._get_common_password('auth_memcache_key')
                },
                'hosts': {
                    'default': 'memcached'
                }
            },
            'oslo_db': {
                'auth': self._get_endpoints_oslo_db_overrides(
                    self.SERVICE_NAME, self.AUTH_USERS)
            },
        }
