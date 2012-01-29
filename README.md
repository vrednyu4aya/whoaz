# Whoaz [![Build Status](https://secure.travis-ci.org/NARKOZ/whoaz.png)](http://travis-ci.org/NARKOZ/whoaz)

Whoaz is a ruby gem that provides a nice way to interact with Whois.Az

## Installation

Command line:

```sh
gem install whoaz
```

Bundler:

```ruby
gem 'whoaz'
```

## Usage

```ruby
whoaz = Whoaz.whois('google.az')
# => #<Whoaz::Whois:0x00000101149158 @organization="Google Inc.", @name="Admin", @address="94043, Mountain View, 1600 Amphitheatre Parkway", @phone="+16503300100", @fax="+16506188571", @email="dns-admin@google.com", @nameservers=["ns1.google.com", "ns2.google.com"]>

whoaz.registered?
# => true
```

#### CLI

```sh
whoaz google.az
```

## Copyright

Copyright (c) 2012 Nihad Abbasov
