# Itamae::Plugin::Resource::Firewalld

[Itamae](https://github.com/ryotarai/itamae) resource plugin to manage [firewalld](https://fedorahosted.org/firewalld/).

[![Build Status](https://travis-ci.org/gongo/itamae-plugin-resource-firewalld.svg?branch=master)](https://travis-ci.org/gongo/itamae-plugin-resource-firewalld)
[![Coverage Status](https://coveralls.io/repos/gongo/itamae-plugin-resource-firewalld/badge.png?branch=master)](https://coveralls.io/r/gongo/itamae-plugin-resource-firewalld?branch=master)
[![Code Climate](https://codeclimate.com/github/gongo/itamae-plugin-resource-firewalld/badges/gpa.svg)](https://codeclimate.com/github/gongo/itamae-plugin-resource-firewalld)

## Usage

```ruby
service 'firewalld' do
  action [:start, :enable]
end

firewalld_zone 'external' do
  interfaces %w(enp0s8 enp0s9)
  services   %w(ssh)

  masquerade true

  notifies  :restart, 'service[firewalld]'
end

firewalld_zone 'public' do
  interfaces %w(enp0s3)
  services   %w(ssh https mysql)
  ports      %w(8080/tcp 4243/udp)

  default_zone true

  notifies :restart, 'service[firewalld]'
end
```

After `itamae` execute:

```
$ sudo firewall-cmd --list-all --zone external
external (active)
  interfaces: enp0s8 enp0s9
  sources:
  services: ssh
  ports:
  masquerade: yes
  forward-ports:
  icmp-blocks:
  rich rules:

$ sudo firewall-cmd --list-all --zone public
public (default, active)
  interfaces: enp0s3
  sources:
  services: https mysql ssh
  ports: 4243/udp 8080/tcp
  masquerade: no
  forward-ports:
  icmp-blocks:
  rich rules:
```

### See also

Demonstration environment [examples](./examples)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'itamae-plugin-resource-firewalld'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install itamae-plugin-resource-firewalld

## Features

Provides a `firewalld_zone` resource that operation of `Zone`:

```ruby
firewalld_zone 'zone_name' do
  name          # [String]

  interfaces    # [Array of string]
  sources       # [Array of string]
  services      # [Array of string]
  ports         # [Array of string]
  forward_ports # [Array of string]
  icmp_blocks   # [Array of string]
  rich_rules    # [Array of string]

  masquerade    # [True / False]
  default_zone  # [True] Ignored other
end
```

**IMPORTANT**

`firewalld_zone` resource performs the processing `firewall-cmd` with [--permanent](http://fedoraproject.org/wiki/FirewallD#Permanent_zone_handling) .

## TODO

Unimplemented:

- Add a new `zone`, `icmptype` and `service`
- Operation of `Direct`, `Lockdown`
- Etc...

I'll be waiting for your pull request :bow:

## Contributing

1. Fork it ( https://github.com/gongo/itamae-plugin-resource-firewalld/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
