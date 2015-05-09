require 'spec_helper'

describe Poof::Syntax do

  context 'when mixed into the Rspec configuration' do

    before do

      RSpec.configure do |conf|
        conf.include described_class
      end
    end

    subject do

      RSpec.describe 'test example' do

        let(:record) { double('ActiveRecord Instance') }

        it 'responds to poof!' do
          expect(Poof::Magic).to receive(:poof!).with(record).once
          expect { poof! record }.to_not raise_error
        end
      end
    end

    it 'exposes the public API to Rspec examples' do
      subject
    end
  end
end