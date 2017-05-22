#!/bin/bash
sudo yum install -y krb5-server krb5-libs krb5-workstation

#install these on clients
#sudo yum install -y krb5-libs krb5-workstation

cat > /etc/krb5.conf <<EOF
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log
[libdefaults]
 default_realm = VERTICACORP.COM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
[realms]
 VERTICACORP.COM = {
  kdc = node3.vm.verticacorp.com
  admin_server = node3.vm.verticacorp.com
 }
[domain_realm]
 .verticacorp.com = VERTICACORP.COM
 verticacorp.com = VERTICACORP.COM
 
EOF



sudo kdb5_util create -s -P admin
 
#start the kdc
sudo /etc/rc.d/init.d/krb5kdc start
 
#start the admin server
sudo /etc/rc.d/init.d/kadmin start
 
#ensure the kdc and admin server start on boot
sudo chkconfig krb5kdc on
sudo chkconfig kadmin on
 
#create the admin principal, make the password "admin"
sudo kadmin.local -q "addprinc -pw admin admin/admin"
sudo kadmin.local -q "addprinc -pw admin cloudera-scm/admin"

sudo echo "*/admin@VERTICACORP.COM *" > /var/kerberos/krb5kdc/kadm5.acl

sudo /etc/rc.d/init.d/kadmin restart
