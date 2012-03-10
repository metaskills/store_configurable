require 'active_support/ordered_options'

module StoreConfigurable
  
  # The heart of StoreConfigurable's data store is this subclass of ActiveSupport's OrderedOptions.
  # They are the heart of Rails' configurations and allow you to dynamically set and get hash keys
  # and values using dot property notation vs the +[]+ hash accessors. 
  # 
  # However, instances of DirtyTrackingOrderedOptions use a recursive lambda via Hash's block 
  # initialization syntax so that you get a dynamic and endless scope on config data. Instances of
  # DirtyTrackingOrderedOptions also make sure that every sub instance of it self also has a handle
  # back to your store's owner. In this way when config attributes are added or values change, 
  # we can mark your ActiveRecord object as dirty/changed.
  class DirtyTrackingOrderedOptions < ::ActiveSupport::OrderedOptions
    
    Recursive = lambda { |h,k| h[k] = h.class.new(h.__store_configurable_owner__) }
    
    attr_accessor :__store_configurable_owner__
    
    def initialize(owner)
      @__store_configurable_owner__ = owner
      super(&Recursive)
    end
    
    def []=(key, value)
      _config_may_change!(key, value)
      super
    end
      
    def delete(key)
      name = key.to_sym
      _config_will_change! if has_key?(name)
      super
    end
      
    def delete_if
      _with_config_keys_may_change! { super }
    end
      
    def dup
      raise NotImplementedError, 'the StoreConfigurable::Object does not support making a copy'
    end
      
    def reject!
      _with_config_keys_may_change! { super }
    end
      
    def clear
      _config_will_change!
      super
    end
    
    
    protected
    
    def _with_config_keys_may_change!
      starting_keys = keys.dup
      yield
      _config_will_change! if starting_keys != keys
      self
    end
      
    def _config_may_change!(key, value)
      name = key.to_sym
      _config_will_change! unless has_key?(name) && self[name] == value
    end
      
    def _config_will_change!
      __store_configurable_owner__._config_will_change!
    end
    
  end
  
end