require 'helper'

class StoreConfigurable::BaseTest < StoreConfigurable::TestCase
  
  it 'is never blank' do
    new_user.config.wont_be_nil
  end
  
  it 'can set and get root attributes' do
    new_user.config.foo = 'foo'
    new_user.config.foo.must_equal 'foo'
  end
  
  it 'can set and get adhoc nested options' do
    options = {:this => 'that'}
    new_user.config.foo.bar.options = options
    new_user.config.foo.bar.options.must_equal options
  end
  
  it 'can serialize to yaml' do
    user_ken.config.foo = 'bar'
    user_ken.config.to_yaml.must_include '--- !omap'
    user_ken.config.to_yaml.must_include ':foo: bar'
  end
  
  it 'wont mark owner as dirty after initial read from database with no existing config' do
    user_ken.config
    user_ken.wont_be :config_changed?
  end
  
  it 'can use uncool hash syntax if you want with varying techniques of strings, symbols and calls' do
    user_ken.config.color = 'black'
    user_ken.config['remember_me'] = true
    user_ken.config['sortable_tables'].direction = 'asc'
    user_ken.config.sortable_tables['column'] = 'updated_at'
    user_ken.save!
    user_ken.reload
    user_ken.config['color'].must_equal 'black'
    user_ken.config[:color].must_equal 'black'
    user_ken.config.remember_me.must_equal true
    user_ken.config.sortable_tables[:direction].must_equal 'asc'
    user_ken.config[:sortable_tables][:column].must_equal 'updated_at'
  end
  
  it 'must be mark owner as dirty after missing getter since that inits a new namespace' do
    user_ken.config.bar
    user_ken.must_be :config_changed?
  end
  
  it 'does not support dup, reject, merge' do
    lambda{ user_ken.config.dup }.must_raise(NotImplementedError) 
    lambda{ user_ken.config.reject{} }.must_raise(NotImplementedError)
    lambda{ user_ken.config.merge({}) }.must_raise(NotImplementedError) 
  end

  describe 'existing data' do
    
    let(:color)       { '#c1c1c1' }
    let(:remember)    { true }
    let(:deep_value)  { StorableObject.new('test') }
    let(:plugin_opts) { Hash[:sort,'asc',:on,true] }
    
    before do
      user_ken.config.color = color
      user_ken.config.remember_me = remember
      user_ken.config.plugin.options = plugin_opts
      user_ken.config.you.should.never.need.to.do.this = deep_value
      user_ken.save!
      @user = User.find(user_ken.id)
    end
    
    it 'wont be dirty after loading' do
      @user.wont_be :config_changed?
    end
    
    it 'can reconsitute saved values' do
      @user.config.color.must_equal color
      @user.config.remember_me.must_equal remember
      @user.config.plugin.options.must_equal plugin_opts
      @user.config.you.should.never.need.to.do.this.must_equal deep_value
    end
    
    it 'wont be dirty after reading saved configs' do
      @user.config.color
      @user.config.remember_me
      @user.config.plugin.options
      @user.config.you.should.never.need.to.do.this
      @user.wont_be :config_changed?
    end
    
    it 'wont be dirty when setting same config values' do
      @user.config.color = color
      @user.config.remember_me = remember
      @user.config.plugin.options = plugin_opts
      @user.config.you.should.never.need.to.do.this = deep_value
      @user.wont_be :config_changed?
    end
    
    it 'must be marked dirty when values change' do
      @user.config.color = 'black'
      @user.must_be :config_changed?
      @user.save!
      @user.config.color.must_equal 'black'
    end
    
    it 'must be marked dirty when clearing' do
      @user.config.clear
      @user.must_be :config_changed?
      @user.save!
      @user.config.must_be :blank?
    end
    
    it 'must be marked dirty when deleting a key' do
      @user.config.delete :color
      @user.must_be :config_changed?
      @user.save!
      @user.config.has_key?(:color).must_equal false
    end
    
    it 'wont be marked dirty when deleting a non-existent key' do
      @user.config.delete :doesnotexist
      @user.wont_be :config_changed?
    end
    
    it 'must be marked dirty when using delete_if' do
      @user.config.delete_if { |k,v| true }
      @user.must_be :config_changed?
      @user.config.must_be :blank?
    end
    
    it 'wont be marked dirty when using delete_if and nothing happens' do
      @user.config.delete_if { |k,v| false }
      @user.wont_be :config_changed?
      @user.config.you.should.never.need.to.do.this = deep_value
    end
    
    it 'must be marked dirty when using reject! on true' do
      @user.config.reject! { |k,v| true }
      @user.must_be :config_changed?
      @user.config.must_be :blank?
    end
    
  end

  
end

