# frozen_string_literal: true

require 'active_record'
require 'active_support/logger'

class Sqlite3Db
  class << self
    def config
      {
        adapter: 'sqlite3',
        database: 'development.sqlite3',
        encoding: 'utf-8',
        pool: 5,
        timeout: 5000
      }
    end

    def setup
      set_logger
      connect
      migrate
    end

    def set_logger
      ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)
    end

    def connect
      ActiveRecord::Base.establish_connection(config)
    end

    def migrate
      create_table(:users) do |t|
        t.string :name
        t.string :email, unique: true
        t.string :password
      end

      create_table(:todos) do |t|
        t.integer :user_id
        t.string :name
        t.boolean :done
        t.boolean :trash
      end
    end

    def create_table(name, &block)
      return if ActiveRecord::Base.connection.table_exists?(name)

      ActiveRecord::Base.connection.create_table(name, &block)
    end
  end
end
