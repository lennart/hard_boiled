## HardBoiled

simply define mapping from you model to a simple hash.

### Installation

    gem install hard-boiled

### Usage

```ruby
require 'hard-boiled'

egg = OpenStruct.new({
  :boil_time => 7,
  :temperature => 99,
  :colour => "beige"
})

HardBoiled::Presenter.define egg do
  time :from => :boil_time
  colour
  temperature :format => "%d ℃"
end # => {
  :time => 7,
  :temperature => "99 ℃",
  :colour => "beige"
}
```

for more examples see the tests in the `spec` directory.

### Similar Projects

If _hard-boiled_ isn't your cup of tea, go and check out other ways to map models
to hashes (for data serialization):

* [Representative](https://github.com/mdub/representative)
* [Tokamak](https://github.com/abril/tokamak)
* [Builder](http://rubygems.org/gems/builder)
* [JSONify](https://github.com/bsiggelkow/jsonify)
* [Argonaut](https://github.com/jbr/argonaut)
* [JSON Builder](https://github.com/dewski/json_builder)
* [RABL](https://github.com/nesquena/rabl)