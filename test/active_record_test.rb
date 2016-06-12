require 'active_record'

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.string :uid, null: false
  end
  add_index :users, :uid, unique: true

  create_table :user2s do |t|
    t.string :uuid, null: false
  end
  add_index :user2s, :uuid, unique: true

  create_table :user3s do |t|
    t.string :uid, null: false
  end
  add_index :user3s, :uid, unique: true

  create_table :user4s do |t|
    t.string :uid
  end
  add_index :user4s, :uid, unique: true

  create_table :user5s do |t|
    t.string :uid, null: false
  end

  create_table :user6s do |t|
    t.string :uid, null: false
  end

  create_table :user7s do |t|
    t.string :uid, null: false
  end

  create_table :user8s do |t|
    t.string :uid, null: false
  end
  add_index :user8s, :uid, unique: true

  create_table :user9s do |t|
    t.string :uid, null: false
  end
  add_index :user9s, :uid, unique: true

  create_table :user10s do |t|
    t.string :uuid, null: false
  end
  add_index :user10s, :uuid, unique: true

  create_table :user11s do |t|
    t.string :uid, null: false
  end
  add_index :user11s, :uid, unique: true

  create_table :multi_users do |t|
    t.string :uid, null: false
    t.string :slug, null: false
  end
  add_index :multi_users, :uid, unique: true
  add_index :multi_users, :slug, unique: true

  create_table :multi_user2s do |t|
    t.string :uuid, null: false
    t.string :slug, null: false
  end
  add_index :multi_user2s, :uuid, unique: true
  add_index :multi_user2s, :slug, unique: true
end

class User < ActiveRecord::Base
  include Uidable
  uidable
end

class User2 < ActiveRecord::Base
  include Uidable
  uidable uid_name: 'uuid'
end

class User3 < ActiveRecord::Base
  include Uidable
  uidable read_only: false
end

class User4 < ActiveRecord::Base
  include Uidable
  uidable presence: false
end

class User5 < ActiveRecord::Base
  include Uidable
  uidable read_only: false

  def gen_uid
    'same_uid'
  end
end

class User6 < ActiveRecord::Base
  include Uidable
  uidable uniqueness: :always, read_only: false
end

class User7 < ActiveRecord::Base
  include Uidable
  uidable uniqueness: :none, read_only: false
end

class User8 < ActiveRecord::Base
  include Uidable
  uidable set_to_param: true
end

class User9 < ActiveRecord::Base
  include Uidable
  uidable scope: true
end

class User10 < ActiveRecord::Base
  include Uidable
  uidable uid_name: 'uuid', scope: true
end

class User11 < ActiveRecord::Base
  include Uidable
  uidable
  UID_SIZE = 128
  def gen_uid
    Array.new(UID_SIZE) { [*'0'..'9'].sample }.join
  end
end

class MultiUser < ActiveRecord::Base
  include Uidable
  uidable
  uidable uid_name: 'slug'
end

class MultiUser2 < ActiveRecord::Base
  include Uidable
  uidable uid_name: 'uuid'
  uidable uid_name: 'slug'
  UID_SIZE = 128
  def gen_uuid
    Array.new(UID_SIZE) { [*'0'..'9'].sample }.join
  end
end

describe Uidable do
  it 'should respond to the uid attribute' do
    u = User.new
    u.respond_to?(:uid).must_equal true
  end

  it 'should assign the uid with 32-bit length string when record is created' do
    u = User.new
    u.uid.must_equal nil
    u.save!
    u.uid.must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
  end

  it 'should change the uid attribute name with given uid_name' do
    u = User2.new
    u.respond_to?(:uid).must_equal false
    u.must_respond_to :uuid
    u.save!
    u.uuid.must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
  end

  describe 'read-only' do
    it 'should be read-only by default' do
      u = User.create
      ori_uid = u.uid
      u.uid = 'assigned_uid'
      u.save!
      u = User.find(u.id)
      u.uid.must_equal ori_uid
    end

    it 'can change uid if read-only is disabled' do
      u = User3.create
      u.uid = 'assigned_uid'
      u.save!
      u = User3.find(u.id)
      u.uid.must_equal 'assigned_uid'
    end
  end

  describe 'presence' do
    it 'should check presence by default' do
      u = User.create
      u.uid = nil
      u.valid?.must_equal false
    end

    it 'can assign uid with nil if presence is disabled' do
      u = User4.create
      u.uid = nil
      u.valid?.must_equal true
    end
  end

  describe 'uniqueness' do
    it 'should check uniqueness when the record is created by default' do
      User5.create
      u = User5.new
      u.valid?.must_equal false
      u2 = User.create
      u3 = User.create
      u3.uid = u2.uid
      u3.valid?.must_equal true
    end

    it 'should check the uniqueness when the record is saved if :always option is given' do
      u = User6.create
      u2 = User6.create
      u2.uid = u.uid
      u2.valid?.must_equal false
    end

    it 'can assign uid with existing one if uniqueness is disabled' do
      u = User7.create
      u2 = User7.create
      u2.uid = u.uid
      u2.valid?.must_equal true
    end
  end

  describe 'set_to_param' do
    it 'should use id as param by default' do
      u = User.create
      u.to_param.must_equal u.id.to_s
    end

    it 'should use uid as param if set_to_param is enabled' do
      u = User8.create
      u.to_param.must_equal u.uid
    end
  end

  describe 'scope' do
    it 'should have no with_uid scope by default' do
      User.respond_to?(:with_uid).must_equal false
    end

    it 'should have the with_uid scope if scope is enabled' do
      User9.must_respond_to :with_uid
    end

    it 'should find a record with uid by the with_uid scope' do
      u = User9.create
      User9.create
      User9.create
      User9.create
      found_u = User9.with_uid(u.uid).take
      found_u.id.must_equal u.id
      found_u.uid.must_equal u.uid
    end

    it 'should have the scope with the changed uid name if uid_name is given and scope is enabled' do
      User10.must_respond_to :with_uuid
      u = User10.create
      User10.create
      User10.create
      User10.create
      found_u = User10.with_uuid(u.uuid).take
      found_u.id.must_equal u.id
      found_u.uuid.must_equal u.uuid
    end
  end

  it 'can override uid generation by given a customized gen_uid method' do
    u = User11.create
    u.uid.size.must_equal User11::UID_SIZE
    u.uid.must_match(/^[0-9]{#{User11::UID_SIZE}}$/)
  end

  describe 'multi' do
    it 'should respond to the uid attribute' do
      u = MultiUser.new
      u.respond_to?(:uid).must_equal true
      u.respond_to?(:slug).must_equal true
    end

    it 'should assign the uid with 32-bit length string when record is created' do
      u = MultiUser.new
      u.uid.must_equal nil
      u.slug.must_equal nil
      u.save!
      u.uid.must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
      u.slug.must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
      u.uid.wont_equal u.slug
    end

    it 'should change the uid attribute name with given uid_name' do
      u = MultiUser2.new
      u.respond_to?(:uid).must_equal false
      u.must_respond_to :uuid
      u.must_respond_to :slug
      u.save!
      u.slug.must_match(/^[a-z0-9]{#{Uidable::DEFAULT_UID_SIZE}}$/)
    end

    it 'can override uid generation by given a customized gen_uid method' do
      u = MultiUser2.create
      u.uuid.size.must_equal MultiUser2::UID_SIZE
      u.uuid.must_match(/^[0-9]{#{MultiUser2::UID_SIZE}}$/)
    end
  end
end
