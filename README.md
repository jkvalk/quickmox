[![Build Status](https://travis-ci.org/jkvalk/quickmox.svg?branch=master)](https://travis-ci.org/jkvalk/quickmox)
[![Gem Version](https://badge.fury.io/rb/quickmox.svg)](http://badge.fury.io/rb/quickmox)
[![Coverage Status](https://coveralls.io/repos/jkvalk/quickmox/badge.svg?branch=master)](https://coveralls.io/r/jkvalk/quickmox?branch=master)

# Quickmox

Quickmox is a Ruby gem for managing Proxmox hosts by using SSH screen-scraping techniques. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'quickmox'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install quickmox

## Usage

```ruby
require 'quickmox'
include Quickmox

hostname = 'host1.example.com'
user = 'root'
pass = 's3cr3t'

host = Host.new(hostname: hostname, username: user, password: pass)
    .connect
    .scan

p host.localname
p host.uptime

host.guests.each do |guest|
    guest.scan
    p guest.status
    guest.params.keys.each do |key|
        puts "#{key}: #{guest.params[key]}"
    end
end if host.is_proxmox?

host.disconnect

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jkvalk/quickmox. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

