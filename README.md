who's
=====
Whois, but shorter and nicer.

It parses the whois info, and returns only the relevant information in a
standard way.

![Screenshot](https://raw.githubusercontent.com/joallard/whos/master/docs/screenshot.png)

Usage
-----
```bash
$ ruby lookup.rb github.com

github.com
----------
registered

Expiration: 2020-10-09 11:20:50 -0700
Creation:   2007-10-09 11:20:50 -0700
Registrar:  MarkMonitor, Inc.
```

### Installation
```bash
$ git clone https://github.com/joallard/whos.git
$ cd whos
$ bundle install

# You're good to go
```

Underlying gems
---------------
Thanks to these gem authors and contributors:
* whois
* whois-parser
