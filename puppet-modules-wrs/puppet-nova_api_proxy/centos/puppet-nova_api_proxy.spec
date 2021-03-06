%global module_dir  nova_api_proxy

Name:           puppet-%{module_dir}
Version:        1.0.0
Release:        %{tis_patch_ver}%{?_tis_dist}
Summary:        Puppet Nova Api Proxy module
License:        Apache-2.0
Packager:       Wind River <info@windriver.com>

URL:            unknown

Source0:        %{name}-%{version}.tar.gz
Source1:        LICENSE

BuildArch:      noarch

BuildRequires: python2-devel

%description
A puppet module for Nova API Proxy

%prep
%autosetup -c %{module_dir}

#
# The src for this puppet module needs to be staged to packstack/puppet/modules
#
%install
install -d -m 0755 %{buildroot}%{_datadir}/puppet/modules/%{module_dir}
cp -R %{name}-%{version}/%{module_dir} %{buildroot}%{_datadir}/puppet/modules

%files
%license  %{name}-%{version}/LICENSE
%{_datadir}/puppet/modules/%{module_dir}

