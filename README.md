[![Build Status](https://travis-ci.org/jkvalk/quickmox.svg?branch=master)](https://travis-ci.org/jkvalk/quickmox)
[![Gem Version](https://badge.fury.io/rb/quickmox.svg)](http://badge.fury.io/rb/quickmox)
[![Coverage Status](https://coveralls.io/repos/jkvalk/quickmox/badge.svg?branch=master)](https://coveralls.io/r/jkvalk/quickmox?branch=master)
[![Code Climate](https://codeclimate.com/github/jkvalk/quickmox/badges/gpa.svg)](https://codeclimate.com/github/jkvalk/quickmox)

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

host = Host.new( SSHTransport.new('hostname','username','password') )
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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jkvalk/quickmox. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

