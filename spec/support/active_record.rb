require "active_record"

ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(
  adapter:  "sqlite3",
  database: ":memory:"
)

class CreateUsersMigration < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :password_reset_token
    end
  end
end

class CreateSessionsMigration < ActiveRecord::Migration
  def up
    create_table :authem_sessions do |t|
      t.string     :role,       null: false
      t.references :subject,    null: false, polymorphic: true
      t.string     :token,      null: false
      t.datetime   :expires_at, null: false
      t.integer    :ttl,        null: false
      t.timestamps
    end
  end
end

RSpec.configure do |config|
  config.before :suite do
    CreateUsersMigration.new.up
    CreateSessionsMigration.new.up
  end

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
