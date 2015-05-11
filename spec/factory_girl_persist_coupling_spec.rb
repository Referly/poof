require 'spec_helper'

describe Poof do

  context 'when used inside of a custom persistence block' do

    before(:all) do
      FactoryGirl.define do
        factory :woman, class: TestModels::Person do
          to_create { |she| Poof.poof!(she).save! }
        end
      end
    end

    before { TestModels::Person.delete_all }

    subject do
      described_class.start
      FactoryGirl.create :woman
      described_class.end
      TestModels::Person.count
    end

    it 'cleans up created instances' do
      expect(subject).to eq 0
    end
  end
end