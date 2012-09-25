module StoreConfigurable
  module Read

    # Our main syntatic interface to the underlying +_config+ store. This method ensures that 
    # +self+, the store's owner, will allways be set in the config object. Hence allowing all 
    # other recursive options to get a handle back to the owner.
    # 
    # The config object can be treated as a Hash but in actuality is an enhanced subclass of 
    # +ActiveSupport::OrderedOptions+ that does two important things. First, it allows you to 
    # dynamically define any nested namespace property. Second, it hooks back into your parent
    # object to notify it of change via ActiveRecord's dirty support.
    # 
    # Example:
    # 
    #   class User < ActiveRecord::Base
    #     store_configurable
    #   end
    #   
    #   user = User.find(42)
    #   user.config.remember_me = true
    #   user.config.sortable_tables.products.sort_on = 'created_at'
    #   user.config.sortable_tables.products.direction = 'asc'
    #   user.changed?        # => true
    #   user.config_changed? # => true
    def config
      _config.__store_configurable_owner__ = self
      _config
    end
    
    # Simple delegation to the underlying data attribute's changed query method.
    def config_changed?
      _config_changed?
    end
    
    # Simple delegation to the underlying data attribute's change array.
    def config_change
      _config_change
    end
    
    # An override to ActiveRecord's accessor for the sole purpoes of injecting +Serialization+
    # behavior so that we can set the context of this owner and ensure we pass that down to 
    # the YAML coder. Doing this on a per instance basis keeps us from trumping all other 
    # +ActiveRecord::AttributeMethods::Serialization::Attribute+ objects.
    def _config
      attrib = @attributes['_config']
      unless attrib.respond_to?(:__store_configurable_owner__)
        attrib.extend Serialization 
        attrib.__store_configurable_owner__ = self
      end
      super
    end
    
    # An override to ActiveRecord's low level read_attribute so we can setup the config object.
    def read_attribute(attr_name)
      config
      super
    end

    # We never want the `_config` key in the list of attributes. This keeps practically keeps
    # ActiveRecord from always saving this serialized column too
    def attributes
      super.tap { |x| x.delete('_config') }
    end
    
  end
end
