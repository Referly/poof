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

    subject { road.speed_limit }

    let(:road) { poof! create(:road_factory, type: :highway) }

    context 'when on the highway' do

        it 'is 55 mph' do
            expect(subject).to eq 55
        end
    end
end
```