# tailwind_ui

This gem is for working with [Tailwind UI](https://tailwindui.com).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add tailwind_ui

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install tailwind_ui

## Usage

First, copy the React (JSX) code from [Tailwind UI](https://tailwindui.com) to a local file.

Then use the `jsx_to_erb` command to convert it to ERB, for example:

`bundle exec jsx_to_erb simple.jsx > app/views/_simple.html.erb`

Only some basic components are currently supported. The plan is to gradually increase the coverage.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andyw8/tailwind_ui.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
