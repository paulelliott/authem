require 'active_record'
require 'logger'

dbconfig = {
  :adapter => 'postgresql',
  :database => 'authem_test',
  :min_messages => 'warning'
}

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(dbconfig.merge('database' => 'postgres', 'schema_search_path' => 'public'))
ActiveRecord::Base.connection.drop_database dbconfig[:database] rescue nil
ActiveRecord::Base.connection.create_database(dbconfig[:database])
ActiveRecord::Base.establish_connection(dbconfig)

class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :sorcery_strategy_users, :force => true do |t|
      t.column :email, :string
      t.column :crypted_password, :string
      t.column :salt, :string
      t.column :remember_token, :string
      t.column :reset_password_token, :string
      t.column :session_token, :string
    end

    create_table :primary_strategy_users, :force => true do |t|
      t.column :email, :string
      t.column :password_digest, :string
      t.column :remember_token, :string
      t.column :reset_password_token, :string
      t.column :session_token, :string
    end
  end

  def self.down
    drop_table :sorcery_strategy_users
    drop_table :primary_strategy_users
  end
end

RSpec.configure do |config|
  config.before(:suite) { TestMigration.up }
end

class SorceryStrategyUser < ActiveRecord::Base
  include Authem::SorceryUser
end

class PrimaryStrategyUser < ActiveRecord::Base
  include Authem::User
end
