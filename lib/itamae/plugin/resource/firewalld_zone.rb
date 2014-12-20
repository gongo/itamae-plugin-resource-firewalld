require 'itamae/resource/base'

module Itamae
  module Plugin
    module Resource
      class FirewalldZone < Itamae::Resource::Base

        define_attribute :action, default: :update
        define_attribute :name, type: String, default_name: true

        define_attribute :masquerade,    type: [TrueClass, FalseClass]
        define_attribute :default_zone,  type: [TrueClass, FalseClass]

        ARRAYABLE_SETTINGS = [
          :interfaces,
          :sources,
          :services,
          :ports,
          :forward_ports,
          :icmp_blocks,
          :rich_rules
        ]

        ARRAYABLE_SETTINGS.each do |name|
          define_attribute name, type: Array
        end

        def pre_action
          ARRAYABLE_SETTINGS.each do |name|
            attributes[name].sort! if attributes[name]
          end
        end

        def set_current_attributes
          ARRAYABLE_SETTINGS.each do |name|
            attributes[name].sort! if attributes[name]
            current[name] = current_setting(name) if attributes[name]
          end

          current.masquerade    = masquerade_enabled? unless attributes.masquerade.nil?
          current.default_zone  = default_zone?       unless attributes.default_zone.nil?
        end

        def action_update(options)
          ARRAYABLE_SETTINGS.each do |name|
            update_setting(name, current[name], attributes[name]) if attributes[name]
          end

          if !attributes.masquerade.nil? && (current.masquerade != attributes.masquerade)
            update_masquerade(attributes.masquerade)
            updated!
          end

          if attributes.default_zone && !current.default_zone
            set_default_zone
            updated!
          end
        end

        private

        #
        # @param  [String]  name      setting name
        # @param  [Array]   current   current.{property_name}
        # @param  [Array]   updated   updated.{property_name}
        #
        def update_setting(name, current, updated)
          #
          # singularize (e.g. forward_ports -> forward-port)
          #
          # TODO: Not beautiful..
          #
          name = name.to_s.gsub('_', '-').chop

          add_args = ["--add-#{name}"].product(updated - (current & updated)).flatten
          remove_args = ["--remove-#{name}"].product(current - updated).flatten

          run_zone_command(add_args) unless add_args.empty?
          run_zone_command(remove_args) unless remove_args.empty?
        end

        def update_masquerade(enabled)
          action = enabled ? 'add' : 'remove'
          run_zone_command(["--#{action}-masquerade"])
        end

        def current_setting(name)
          name = name.to_s.gsub('_', '-')
          run_zone_command(["--list-#{name}"]).stdout.strip.split.sort
        end

        def masquerade_enabled?
          run_zone_command(['--query-masquerade'], error: false).success?
        end

        def run_zone_command(args, options = {})
          command = ['firewall-cmd', '--zone', attributes.name, '--permanent']
          run_command(command + args, options)
        end

        def default_zone?
          command = ['firewall-cmd', '--get-default-zone']
          run_command(command).stdout.strip == attributes.name
        end

        def set_default_zone
          run_command(['firewall-cmd', '--set-default-zone', attributes.name])
        end
      end
    end
  end
end
