require 'spec_helper'

describe Poof::Magic do

  describe '#poof!' do

    before(:all) do

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
      end

      TestModels::Car.delete_all
    end

    it 'ensures a record will be removed from the database' do
      Poof::Magic.start
      record = poof!(TestModels::Car.create! make: "Chevy", model: "Volt", year: Date.today.year)
      expect { TestModels::Car.find record.id }.to_not raise_error
      Poof::Magic.end
      expect { TestModels::Car.find record.id }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end