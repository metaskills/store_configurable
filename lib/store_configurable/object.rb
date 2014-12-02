require 'active_support/proxy_object'

module StoreConfigurable

  # The is the object returned by the +config+ method. It does nothing more than delegate
  # all calls to a tree of +DirtyTrackingOrderedOptions+ objects which are basically hashes.
  #
  class Object < ::ActiveSupport::ProxyObject

    OMAP_CONVERTER = lambda do |config|
      ::ActiveSupport::OrderedHash[config.to_a].tap do |omap|
        omap.each { |k,v| omap[k] = OMAP_CONVERTER.call(v) if v.is_a?(::Hash) }
      end
    end

    YAML_LOADER = lambda do |options, key, value|
      value.is_a?(::Hash) ? value.each { |k,v| YAML_LOADER.call(options.send(:[],key), k, v) } :
        options.send(:[]=, key, value)
    end

    # Class methods so the +StoreConfigurable::Object+ responds to +dump+ and +load+ which
    # allows it to conform to ActiveRecord's coder requirement via its serialize method
    # that we use.
    #
    # The +dump+ method serializes the raw data behind the +StoreConfigurable::Object+ proxy
    # object. This means that we only store pure ruby primitives in the datbase, not our
    # proxy object's YAML type.
    #
    # The +load+ method mimics +ActiveRecord::Coders::YAMLColumn+ internals by retuning a
    # new object when needed as well as making sure that the YAML we are process if of the
    # same type. When reconstituting  a +StoreConfigurable::Object+ we must set the store's
    # owner as this does. That way as our recursive  lambda loader regenerates the tree of
    # config data, we always have a handle for each +DirtyTrackingOrderedOptions+ object to
    # report state changes back to the owner. Finally, after each load we make sure to clear
    # out changes so reloaded objects are not marked as dirty.
    #
    module Coding

      def dump(value)
        config = (value.nil? ? StoreConfigurable::Object.new : value).__config__
        YAML.dump OMAP_CONVERTER.call(config)
      end

      def load(yaml, owner=nil)
        return StoreConfigurable::Object.new if yaml.blank?
        return yaml unless yaml.is_a?(String) && yaml =~ /^---/
        stored_data = YAML.load(yaml)
        unless stored_data.is_a?(Hash)
          raise ActiveRecord::SerializationTypeMismatch,
           "Attribute was supposed to be a Hash, but was a #{stored_data.class}"
        end
        config = StoreConfigurable::Object.new
        config.__store_configurable_owner__ = owner
        stored_data.each { |k,v| YAML_LOADER.call(config, k, v) }
        owner.changed_attributes.delete('_config') if owner
        config
      end

    end

    # Instance methods for +StoreConfigurable::Object+ defined and included in a module so
    # that if you ever wanted to, you could redefine these methods and +super+ up.
    #
    module Behavior

      attr_accessor :__store_configurable_owner__

      def __config__
        @__config__ ||= DirtyTrackingOrderedOptions.new(@__store_configurable_owner__)
      end

      private

      def method_missing(method, *args, &block)
        __config__.__send__ method, *args, &block
      end

    end

    extend Coding
    include Behavior

  end

end

