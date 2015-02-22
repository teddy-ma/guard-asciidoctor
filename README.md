# Guard::Asciidoctor

Watches Asciidoc files, compiles them to HTML on change.

## Install

Please be sure to have [Guard](https://github.com/guard/guard) installed before continuing.

Add Guard::Asciidoctor to your `Gemfile`:

```ruby
group :development do
  gem 'guard-asciidoctor'
end
```

Add guard definition to your Guardfile by running this command:

```bash
$ guard init asciidoctor
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/guard-asciidoctor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
