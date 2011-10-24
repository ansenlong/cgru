# This is RPM spec file:

%define _topdir %(echo $PWD)/RPM

Summary:       Afanasy common files
License:       GPL
Name:          afanasy-common
Version:       @VERSION@
Release:       @RELEASE@
Group:         Applications/Graphics

%description
Afanasy common files.

%prep

%build

%install
cd ../..
dirs="opt"
for dir in $dirs; do
   mkdir -p $RPM_BUILD_ROOT/$dir
   mv $dir/* $RPM_BUILD_ROOT/$dir
done

%files
%defattr(-,root,root)
/opt

%clean

%post
echo "Afanasy common POST INSTALL"
[ -d /opt/cgru/afanasy/python ] && find /opt/cgru/afanasy/python -type d -exec chmod a+rwx {} \;
exit 0

%preun
echo "Afanasy common PRE REMOVE: $1"
[ "$1" != "0" ] && exit 0
pkill afcmd || true
echo "Cleaning afanasy/python"
[ -d /opt/cgru/afanasy/python ] && find /opt/cgru/afanasy/python -type f -name *.pyc -exec rm -vf {} \;
exit 0