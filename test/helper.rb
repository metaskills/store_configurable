require 'rubygems'
require 'bundler'
require "bundler/setup"
Bundler.require
require 'store_configurable'
require 'active_record/base'
require 'minitest/autorun'
require 'logger'


ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__),'debug.log'))
ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'


module StoreConfigurable
  class TestCase < MiniTest::Spec
    
    before { setup_environment }
    
    let(:new_user) { User.new }
    let(:user_ken) { User.find_by_email('ken@metaskills.net') }
    let(:post_sc)  { Post.find_by_title('StoreConfigurable') }
    
    def setup_environment
      setup_database
      setup_data
    end
    
    protected

    def setup_database
      ActiveRecord::Base.class_eval do
        silence do
          connection.create_table :users, :force => true do |t|
            t.string  :name, :email
            t.text    :_config
          end
          connection.create_table :posts, :force => true do |t|
            t.string  :title, :body
          end
        end
      end
    end
    
    def setup_data
      User.create :name => 'Ken Collins', :email => 'ken@metaskills.net'
      Post.create :title => 'StoreConfigurable', :body => 'test'
    end
    
  end
end

class StorableObject
  attr_accessor :value
  def initialize(value) ; @value = value ; end
  def ==(other) ; value == other.value ; end
end

class User < ActiveRecord::Base
  store_configurable
end

class Post < ActiveRecord::Base  
end
