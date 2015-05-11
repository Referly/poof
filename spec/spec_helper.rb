require_relative '../simplecov_custom_profiles'
SimpleCov.start 'poof'
require 'rspec/support/spec'
require 'byebug'
require 'poof'
require 'active_record'
require_relative 'support/test_models'
require 'factory_girl'

RSpec.configure { |conf| conf.include Poof::Syntax }

ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'example.db'
)

ActiveRecord::Schema.define do
  unless ActiveRecord::Base.connection.tables.include? 'cars'
    create_table :cars do |table|
      table.string  :make
      table.string  :model
      table.date    :year
      table.timestamps
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'people'
    create_table :people do |table|
      table.string :name
      table.string :age
      table.timestamps
    end
  end

  unless ActiveRecord::Base.connection.tables.include? 'pets'
    create_table :pets do |table|
      table.integer :owner_id
      table.string :name
      table.timestamps
    end
  end
end