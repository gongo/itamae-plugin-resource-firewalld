require 'helper'
require 'itamae/plugin/resource/firewalld_service'

module Itamae
  module Plugin
    module Resource
      # Stub
      class FirewalldService
        def send_file(from, to)
          @local_path = from
        end

        def local_path
          @local_path
        end
      end

      class TestFirewalldService < Test::Unit::TestCase
        setup do
          @resource = FirewalldService.new(stub, 'test-service')
        end

        sub_test_case '#action_delete' do
          setup do
            @resource.attributes.action = :delete
          end

          sub_test_case 'predefined service' do
            setup do
              @resource.expects(:run_command)
                .with(['firewall-cmd', '--permanent', '--list-services'])
                .returns(stub(stdout: 'service1 service2 test-service'))
            end

            test 'delete service' do
              @resource.expects(:run_command).with(['firewall-cmd', '--permanent', '--delete-service', 'test-service'])
              @resource.expects(:notify)
              @resource.run
            end
          end

          sub_test_case 'undefined service' do
            setup do
              @resource.expects(:run_command)
                .with(['firewall-cmd', '--permanent', '--list-services'])
                .returns(stub(stdout: 'service1 service2'))
            end

            test 'delete service (noop)' do
              @resource.expects(:notify).never
              @resource.run
            end
          end
        end

        sub_test_case '#action_create' do
          setup do
            @resource.attributes.action = :create
            @resource.stubs(:runner).returns(stub(tmpdir: ::Dir.tmpdir))
            @resource.stubs(:move_file)
            @resource.stubs(:run_specinfra).with(:move_file, is_a(String), is_a(String))

            @resource.expects(:notify)
          end

          sub_test_case 'undefined service' do
            setup do
              @resource.stubs(:current_status).returns(:undefined)
            end

            test 'create service' do
              @resource.run

              assert ::File.exists?(@resource.local_path )
            end
          end

          sub_test_case 'predefined service' do
            setup do
              @resource.stubs(:current_status).returns(:defined)
              @resource.stubs(:run_specinfra)
                .with(:get_file_content, '/etc/firewalld/services/test-service.xml')
                .returns(stub(stdout: <<-EOS))
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>test-service</short>
  <description>test-service description</description>
  <port protocol="tcp" port="2222"/>
  <port protocol="udp" />
  <port protocol="tcp" port="80-82"/>
  <module name="test-module"/>
  <destination ipv4="224.0.0.251" ipv6="ff02::fb"/>
</service>
                 EOS
            end

            test 'update service' do
              @resource.attributes.short       = 'test-service!!'
              @resource.attributes.description = 'test-service update description'
              @resource.attributes.ports       = ['2222-2224/udp', '80/tcp', 'igmp']
              @resource.attributes.module_name = 'new-test-module'
              @resource.attributes.to_ipv4     = '172.17.0.1'
              @resource.attributes.to_ipv6     = 'ffff::fc'
              @resource.run

              assert_equal 'test-service',                   @resource.current.short
              assert_equal 'test-service description',       @resource.current.description
              assert_equal ['2222/tcp', '80-82/tcp', 'udp'], @resource.current.ports
              assert_equal 'test-module',                    @resource.current.module_name
              assert_equal '224.0.0.251',                    @resource.current.to_ipv4
              assert_equal 'ff02::fb',                       @resource.current.to_ipv6

              root = REXML::Document.new(File.read(@resource.local_path))
              service = root.elements['/service'].elements

              assert_equal @resource.attributes.short,       service['short'].text
              assert_equal @resource.attributes.description, service['description'].text
              assert_equal 'udp',                            service[1, 'port'].attributes['protocol']
              assert_equal '2222-2224',                      service[1, 'port'].attributes['port']
              assert_equal 'tcp',                            service[2, 'port'].attributes['protocol']
              assert_equal '80',                             service[2, 'port'].attributes['port']
              assert_equal 'igmp',                           service[3, 'port'].attributes['protocol']
              assert_equal '',                               service[3, 'port'].attributes['port']
              assert_equal @resource.attributes.module_name, service['module'].attributes['name']
              assert_equal @resource.attributes.to_ipv4,     service['destination'].attributes['ipv4']
              assert_equal @resource.attributes.to_ipv6,     service['destination'].attributes['ipv6']
            end
          end
        end
      end
    end
  end
end
