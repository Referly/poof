module TestModels
  class Pet < ActiveRecord::Base
    belongs_to :owner, class_name: "TestModels::Person"
  end
end