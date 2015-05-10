[![Circle CI](https://circleci.com/gh/Referly/poof.svg?style=svg)](https://circleci.com/gh/Referly/poof)
# poof
poof Ruby Gem - a gem for cleaning up test ActiveRecord instances

# usage

Add the following to your spec_helper.rb (or wherever you setup your RSpec examples)

```ruby
RSpec.configure do |conf|
    conf.include described_class
end
```