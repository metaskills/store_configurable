module StoreConfigurable

  # This module's behavior is injected into +ActiveRecord::AttributeMethods::Serialization::Attribute+
  # class which is a mini state machine for serialized objects. It allows us to both set the store's
  # owner as well as overwrite the +unserialize+ method to give the coder both the YAML and owner
  # context. This is done via the +_config+ attribute reader override.
  #
  module Serialization

    attr_accessor :__store_configurable_owner__

    def unserialize(v)
      self.state = :unserialized
      self.value = coder.load(v, __store_configurable_owner__)
    end

  end

end
