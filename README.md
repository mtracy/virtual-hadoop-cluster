# A CDH virtual Hadoop cluster

With these files you can setup and provision a locally running, virtual Hadoop cluster in real distributed fashion for trying out Hadoop and related technologies.

## Specs

The number of virtual machines to spin up, the amount of ram per VM, and the number of cpu threads per VM is configurable in the file `config.json`, but by default it will create a cluster with the following specs:
* 3 VMs
* 6GB ram per VM
* 8 virtual threads per VM
* MIT KDC running on node3-vm

The FQDN of the machines follow the pattern "nodeX-vm.verticacorp.com" where that "X" is a number. The IP addresses follow the pattern "10.0.10.1X" where "X" is the corresponding node ID. For example, the virtual machine with hostname "node2-vm.verticacorp.com" will have IP address "10.0.10.12". 

By default, Cloudera Manager will be installed on node1-vm (10.0.10.11), and a KDC will be installed on node3-vm (10.0.10.13).

## Usage

First install [VirtualBox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://www.vagrantup.com/downloads.html), and [Ansible](https://docs.ansible.com/ansible/intro_installation.html).

Clone this repo and start the cluster.

```bash
git clone https://github.com/mtracy/virtual-hadoop-cluster.git
cd virtual-hadoop-cluster
# optionally modify config.json
# vi config.json
vagrant up
```

Go to the [Cloudera Manager web console](http://10.0.10.11:7180) and follow the installation instructions. 

You can add entries to your local `/etc/hosts` file to make accessing the VM web services easier, but this isn't mandatory. But the entries will look like this

```
10.0.10.11 node1-vm.verticacorp.com node1-vm
10.0.10.12 node2-vm.verticacorp.com node2-vm
10.0.10.13 node3-vm.verticacorp.com node3-vm
```

After you have installed Hadoop serviced through CDM, you can use the `startComponents.sh` script to programmatically start services. You might need to change the variables at the top of the script to get it to work though. Specifically, I changed the name of my cluster in CDM to "test", so you will need to adjust your cluster or script accordingly. You can just run it by itsel, i.e. 
```bash
./startComponents.sh
```

The script will wait until the CDM server is able to respond to API requests, and then will submit a request to start all services in the cluster. It will also wait until the request to start all services has completed. If the request was successful, then it will terminate. If the request was not successful, it will sleep for 30 seconds and then try again. If it fail again, it will sleep for 100 seconds and then give another pair of attempts. If all of these attempts fail then it will not try again.


### Kerberos

As mentioned above, an MIT KDC will be installed by default on node3-vm. You can use this to kerberize your CDH cluster. In the CDM Kerberos Wizard, use realm `VERTICACORP.COM` and principal `admin/admin` with password `admin`. Also, let CDM manage the krb5.conf file.