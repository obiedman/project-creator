# MiseEnPlace

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/mise_en_place`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mise_en_place'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mise_en_place

## Usage

Basic usage is `mise_en_place PROJECT_NAME`.

By default Mise looks in the current directory and up for a .mise_en_place.yml file, but you can specify the location of a config file with `-c` or `--config`.

A config file should look something like this:

```yaml
---
- default:
  - js:
    - index.js
    - subfolder:
      - something.js
  - index.html
  - images

- html:
  - index.html
  - contact.html
```
The `default` structure is required, and will be used in the absence of the project flag. To use a different structure specify the type with `-p` or `--project`
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pmo3/mise_en_place.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
