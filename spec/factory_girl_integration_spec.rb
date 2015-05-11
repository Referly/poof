require 'spec_helper'

FactoryGirl.define do
  factory :cat, class: TestModels::Pet do
    owner
    name "Kitty"
  end

  factory :dog, class: TestModels::Pet do
    owner { Poof::Magic.get(:man) }
    name "Fido"
  end
end

FactoryGirl.define do
  factory :owner, class: TestModels::Person do
  end

  factory :man, parent: :owner do
  end
end

describe 'building a pet with FactoryGirl' do

  before(:each) { TestModels::Person.delete_all }

  subject do
    Poof.start
    FactoryGirl.build pet_factory
    Poof.end
    TestModels::Person.count
  end

  let(:pet_factory) { :cat }

  it 'leaves the owner instance behind' do
    expect(subject).to eq 1
  end

  context 'when using poof' do

    let(:pet_factory) { :dog }

    it 'removes the owner instance' do
      expect(subject).to eq 0
    end
  end
end
