require 'spec_helper'

describe Poof::Magic do

  describe '#poof!' do

    before(:all) do
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