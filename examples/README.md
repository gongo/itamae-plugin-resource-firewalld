`Itamae::Plugin::Resource::Firewalld` demonstration virtual machine.

Usage
--------------------

### Preparation

```sh
$ cd /path/to/itamae-plugin-resource-firewalld/
$ bundle install --path vendor/bundle
```

### Provision

```sh
$ cd ./examples/
$ vagrant up
$ bundle exec itamae ssh -h default --vagrant recipe.rb
 INFO : Starting Itamae...
 INFO : Recipe: /path/to/itamae-plugin-resource-firewalld/examples/recipe.rb
 INFO :    service[firewalld]
 INFO :       action: start
 INFO :          running will change from 'false' to 'true'
 INFO :       action: enable
 INFO :          enabled will change from 'false' to 'true'
 INFO :    firewalld_service[my-ssh]
 INFO :       action: create
 INFO :       Notifying restart to service resource 'firewalld-add-service' (delayed)
 INFO :    service[firewalld-add-service]
 INFO :       action: restart
 INFO :    firewalld_zone[home]
 INFO :       action: update
 INFO :          services will change from '["dhcpv6-client", "ipp-client", "mdns", "samba-client", "ssh"]' to '["samba", "ssh", "vnc-server"]'
 INFO :          ports will change from '[]' to '["1900/udp", "32469/tcp", "5353/udp"]'
 INFO :       Notifying restart to service resource 'firewalld' (delayed)
 INFO :    firewalld_zone[public]
 INFO :       action: update
 INFO :          services will change from '["dhcpv6-client", "ssh"]' to '["https", "my-ssh", "mysql", "ssh"]'
 INFO :       Notifying restart to service resource 'firewalld' (delayed)
 INFO :    service[firewalld-add-service]
 INFO :       action: restart
 INFO :    service[firewalld]
 INFO :       action: restart```

### Confirmation

```sh
$ vagrant ssh
[vagrant@localhost ~]$ sudo systemctl is-enabled firewalld
enabled

[vagrant@localhost ~]$ sudo firewall-cmd --list-all --zone home
home
  interfaces:
  sources:
  services: samba ssh vnc-server
  ports: 5353/udp 32469/tcp 1900/udp
  masquerade: no
  forward-ports:
  icmp-blocks:
  rich rules:

[vagrant@localhost ~]$ sudo firewall-cmd --list-all --zone public
public (default, active)
  interfaces: enp0s3
  sources:
  services: https my-ssh mysql ssh
  ports:
  masquerade: no
  forward-ports:
  icmp-blocks:
  rich rules:

[vagrant@localhost ~]$ sudo cat /etc/firewalld/services/my-ssh.xml # formatting
<?xml version='1.0' encoding='UTF-8'?>
<service>
  <short>my-ssh</short>
  <description>My perfect ssh!!</description>
  <port port='2222' protocol='tcp'/>
</service>
```
