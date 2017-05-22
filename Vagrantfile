Vagrant.configure("2") do |config|

  config.ssh.insert_key = false
  config.vm.box = "omalley/structor-centos6.7"

  clusterconf = JSON.parse( IO.read( "config.json" ), opts = { symbolize_names: true } )
  clusterconf[:vm_cpus] ||= 8
  clusterconf[:vm_mem] ||= 6144
  clusterconf[:num_nodes] ||= 3


  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 6144 ]
    vb.customize ["modifyvm", :id, "--cpus", 8 ]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  N = clusterconf[:num_nodes]
  (1..N).each do |machine_id|
    config.vm.define "node#{machine_id}-vm" do |machine|
      machine.vm.hostname = "node#{machine_id}-vm.verticacorp.com"
      machine.vm.network :private_network, ip: "10.0.10.#{10+machine_id}"

      if machine_id == N
        machine.vm.provision :ansible do |ansible|
          ansible.playbook = "common.yml"
          ansible.limit = "all"
        end
      end
    end
  end
end