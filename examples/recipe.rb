require 'itamae/plugin/resource/firewalld'

service 'firewalld' do
  action [:start, :enable]
end

firewalld_service 'my-ssh' do
  short       'my-ssh'
  description 'My perfect ssh!!'
  port        '2222'
  protocol    'tcp'

  #
  # Necessary to restart before use added service.
  # Because `firewald_serivce` is permanent configuration.
  #
  notifies :restart, 'service[firewalld-add-service]'
end

service 'firewalld-add-service' do
  name   'firewalld'
  action :restart

  notifies :update, 'firewalld_zone[public]'
end

firewalld_zone 'home' do
  services  %w(samba ssh vnc-server)
  ports     %w(1900/udp 5353/udp 32469/tcp)

  notifies :restart, 'service[firewalld]'
end

firewalld_zone 'public' do
  services     %w(ssh https mysql my-ssh)
  default_zone true

  notifies :restart, 'service[firewalld]'
end
