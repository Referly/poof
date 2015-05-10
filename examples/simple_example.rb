require 'spec_helper'

describe 'speed limit' do

  before(:all) { Poof.start }

  after(:all) { Poof.end }

  subject { road.speed_limit }

  context 'when on the highway' do

    let(:road) { poof! create(:road_factory, type: :highway) }

    it 'is 55 mph' do
      expect(subject).to eq 55
    end
  end

  context 'when near children' do

    let(:road) { poof! create(:road_factory, type: :school_road) }

    it 'is 25 mph' do
      expect(subject).to eq 25
    end
  end
end