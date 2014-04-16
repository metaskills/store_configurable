require 'active_support/concern'

module StoreConfigurable
  module Base

    extend ActiveSupport::Concern

    module ClassMethods

      # To use StoreConfigurable, you must create create a +_config+ colun in the mdoel's table.
      # Make sure that you declare this column as a text type, so there's plenty of room.
      #
      #   class AddStoreConfigurableField < ActiveRecord::Migration
      #     def up
      #       add_column :users, :_config, :text
      #     end
      #     def down
      #       remove_column :users, :_config
      #     end
      #   end
      #
      # Next declare that your model uses StoreConfigurable with the +store_configurable+ method.
      # Please read the +config+ documentation for usage examples.
      #
      #   class User < ActiveRecord::Base
      #     store_configurable
      #   end
      def store_configurable
        serialize '_config', StoreConfigurable::Object
        include Read
      end

    end

  end
end

ActiveSupport.on_load(:active_record) { include StoreConfigurable::Base }
