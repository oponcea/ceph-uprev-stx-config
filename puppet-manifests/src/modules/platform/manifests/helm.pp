class platform::helm::repository::params(
  $source_helm_repo_dir = '/opt/cgcs/helm_charts',
  $target_helm_repo_dir = '/www/pages/helm_charts',
) {}

class platform::helm
  inherits ::platform::helm::repository::params {

  include ::platform::kubernetes::params

  if $::platform::kubernetes::params::enabled {
    file {$source_helm_repo_dir:
      ensure  => directory,
      path    => $source_helm_repo_dir,
      owner   => 'www',
      require => User['www']
    }

    -> file {$target_helm_repo_dir:
      ensure  => directory,
      path    => $target_helm_repo_dir,
      owner   => 'www',
      require => User['www']
    }

    if (str2bool($::is_initial_config) and $::personality == 'controller') {

      if str2bool($::is_initial_config_primary) {

        Class['::platform::kubernetes::master']

        # TODO(jrichard): Upversion tiller image to v2.11.1 once released.
        -> exec { 'load tiller docker image':
          command   => 'docker image pull gcr.io/kubernetes-helm/tiller:v2.12.1',
          logoutput => true,
        }

        # TODO(tngo): If and when tiller image is upversioned, please ensure armada compatibility as part of the test
        -> exec { 'load armada docker image':
          command   => 'docker image pull quay.io/airshipit/armada:f807c3a1ec727c883c772ffc618f084d960ed5c9',
          logoutput => true,
        }

        -> exec { 'create service account for tiller':
          command   => 'kubectl --kubeconfig=/etc/kubernetes/admin.conf create serviceaccount --namespace kube-system tiller',
          logoutput => true,
        }

        -> exec { 'create cluster role binding for tiller service account':
          command   => 'kubectl --kubeconfig=/etc/kubernetes/admin.conf create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller', # lint:ignore:140chars
          logoutput => true,
        }

        # TODO(jrichard): Upversion tiller image to v2.11.1 once released.
        -> exec { 'initialize helm':
          environment => [ 'KUBECONFIG=/etc/kubernetes/admin.conf', 'HOME=/home/wrsroot' ],
          command     => 'helm init --skip-refresh --service-account tiller --node-selectors "node-role.kubernetes.io/master"="" --tiller-image=gcr.io/kubernetes-helm/tiller@sha256:022ce9d4a99603be1d30a4ca96a7fa57a45e6f2ef11172f4333c18aaae407f5b', # lint:ignore:140chars
          logoutput   => true,
          user        => 'wrsroot',
          group       => 'wrs',
          require     => User['wrsroot']
        }

        exec { "bind mount ${target_helm_repo_dir}":
          command => "mount -o bind -t ext4 ${source_helm_repo_dir} ${target_helm_repo_dir}",
          require => Exec['add local starlingx helm repo']
        }
      } else {
        exec { 'initialize helm':
          environment => [ 'KUBECONFIG=/etc/kubernetes/admin.conf', 'HOME=/home/wrsroot' ],
          command     => 'helm init --client-only',
          logoutput   => true,
          user        => 'wrsroot',
          group       => 'wrs',
          require     => User['wrsroot']
        }
      }

      exec { 'restart lighttpd for helm':
        require   => [File['/etc/lighttpd/lighttpd.conf', $target_helm_repo_dir], Exec['initialize helm']],
        command   => 'systemctl restart lighttpd.service',
        logoutput => true,
      }

      -> exec { 'generate helm repo index on target':
        command   => "helm repo index ${target_helm_repo_dir}",
        logoutput => true,
        user      => 'www',
        group     => 'www',
        require   => User['www']
      }

      -> exec { 'add local starlingx helm repo':
        before      => Exec['Stop lighttpd'],
        environment => [ 'KUBECONFIG=/etc/kubernetes/admin.conf' , 'HOME=/home/wrsroot'],
        command     => 'helm repo add starlingx http://127.0.0.1/helm_charts',
        logoutput   => true,
        user        => 'wrsroot',
        group       => 'wrs',
        require     => User['wrsroot']
      }
    }
  }
}
