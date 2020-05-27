#!/bin/bash
host_machine_os=centos7
#Change by User
host_machine_profile_id=xccdf_org.ssgproject.content_profile_standard
#Change by User
host_machine_datastream=./scap-security-guide/ssg-centos7-ds.xml

echo $host_machine_profile_id
echo "Changing values in hardening script"
sed -i 's|PROFILE_ID|'"${host_machine_profile_id}"'|g' os-hardening.sh
sed -i 's|DATASTREAM|'"${host_machine_datastream}"'|g' os-hardening.sh

sh os-hardening.sh

sed -i 's|'"${host_machine_profile_id}"'|PROFILE_ID|g' os-hardening.sh
sed -i 's|'"${host_machine_datastream}"'|DATASTREAM|g' os-hardening.sh
