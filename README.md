[![Circle CI](https://circleci.com/gh/Referly/poof.svg?style=svg)](https://circleci.com/gh/Referly/poof)
# poof
poof Ruby Gem - a gem for cleaning up test ActiveRecord instances

# usage

Add the following to your spec_helper.rb (or wherever you setup your RSpec examples)

```ruby
require 'poof'

RSpec.configure do |conf|
    conf.include Poof::Syntax
end
```

Then in your example

```ruby
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
```

That's it, the records created for the test will be cleaned up for you automatically.