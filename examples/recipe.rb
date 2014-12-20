require 'itamae/plugin/resource/firewalld'

service 'firewalld' do
  action [:start, :enable]
end

firewalld_zone 'home' do
  services  %w(samba ssh vnc-server)
  ports     %w(1900/udp 5353/udp 32469/tcp)

  notifies :restart, 'service[firewalld]'
end

firewalld_zone 'public' do
  services     %w(ssh https mysql)
  default_zone true

  notifies :restart, 'service[firewalld]'
end
