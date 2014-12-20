require 'helper'
require 'itamae/plugin/resource/firewalld_zone'

module Itamae
  module Plugin
    module Resource
      class TestFirewalldZone < Test::Unit::TestCase
        setup do
          @resource = FirewalldZone.new(stub, 'public')
        end

        sub_test_case 'settings' do
          setup do
            #
            # $ firewall-cmd --zone public --list-all
            # public (default, active)
            #   ..
            #   services: pop3s ssh
            #   ..
            #
            @resource.stubs(:run_zone_command)
              .with(['--list-services'])
              .returns(stub(stdout: 'pop3s ssh'))
          end

          test 'Change the setting' do
            @resource.attributes.services = ['ssh', 'http', 'smtp']
            @resource.expects(:run_zone_command).with(['--add-service', 'http', '--add-service', 'smtp'])
            @resource.expects(:run_zone_command).with(['--remove-service', 'pop3s'])
            @resource.expects(:notify)
            @resource.run
          end

          test 'No change the setting (noop)' do
            @resource.attributes.services = ['ssh', 'pop3s']
            @resource.expects(:notify).never
            @resource.run
          end
        end

        sub_test_case 'masquerade' do
          sub_test_case 'enable' do
            setup do
              #
              # $ firewall-cmd --zone public --query-masquerade
              # yes
              #
              @resource.stubs(:masquerade_enabled?).returns(true)
            end

            test 'To enbale (noop)' do
              @resource.attributes.masquerade = true
              @resource.expects(:notify).never
              @resource.run
            end

            test 'To disable' do
              @resource.attributes.masquerade = false
              @resource.expects(:run_zone_command).with(['--remove-masquerade'])
              @resource.expects(:notify)
              @resource.run
            end
          end

          sub_test_case 'disable' do
            setup do
              #
              # $ firewall-cmd --zone public --query-masquerade
              # no
              #
              @resource.stubs(:masquerade_enabled?).returns(false)
            end

            test 'To enable' do
              @resource.attributes.masquerade = true
              @resource.expects(:run_zone_command).with(['--add-masquerade'])
              @resource.expects(:notify)
              @resource.run
            end

            test 'To disable (noop)' do
              @resource.attributes.masquerade = false
              @resource.expects(:notify).never
              @resource.run
            end
          end
        end

        sub_test_case 'default_zone' do
          setup do
            @resource.stubs(:run_command)
              .with(['firewall-cmd', '--get-default-zone'])
              .returns(stub(stdout: 'home'))
          end

          test 'Set default zone' do
            @resource.attributes.default_zone = true
            @resource.expects(:set_default_zone)
            @resource.expects(:notify)
            @resource.run
          end

          sub_test_case 'already default zone' do
            setup do
              @resource.stubs(:run_command)
                .with(['firewall-cmd', '--get-default-zone'])
                .returns(stub(stdout: 'public'))
            end

            test 'Set default zone (noop)' do
              @resource.attributes.default_zone = true
              @resource.expects(:set_default_zone).never
              @resource.expects(:notify).never
              @resource.run
            end

            test 'Do not perform unset default zone (noop)' do
              @resource.attributes.default_zone = false
              @resource.expects(:notify).never
              @resource.run
            end
          end
        end
      end
    end
  end
end
