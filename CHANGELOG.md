# Changelog

## 0.2.1 (2016-03-28)

  * Relax Rack dependency to allow for Rack 2 ([Tyler Ewing][zoso10])

## 0.2.0 (2016-03-28)

  * Normalize redirect URL to avoid XSS vulnerability ([Thomas Maurer][tma])
  * Remove `:force_ssl` option in favor of using [rack-ssl][rack-ssl]
    ([Nathaniel Bibler][nbibler])

[rack-ssl]: http://rubygems.org/gems/rack-ssl

## 0.1.0 (2014-04-16)

  * Add `:force_ssl` option ([Jeff Carbonella][jcarbo])

## 0.0.9 (2014-02-14)

  * Add `:if` option ([Nick Ostrovsky][firedev])
  * Improve documentation ([Joost Schuur][jschuur])

## 0.0.8 (2012-06-22)

  * Switch to `Addressable::URI` for URI parsing ([Tyler Hunt][tylerhunt])

## 0.0.7 (2012-06-21)

  * Fix handling of URLs containing `|` characters ([Tyler Hunt][tylerhunt])

## 0.0.6 (2012-06-21)

  * Prevent redirect if the canonical host is `nil` ([Tyler Hunt][tylerhunt])

## 0.0.5 (2012-06-21)

  * Rename `ignored_hosts` option to `ignore` ([Tyler Hunt][tylerhunt])

## 0.0.4 (2012-06-20)

  * Add option to ignored certain hosts ([Eric Allam][rubymaverick])
  * Add tests ([Nathaniel Bibler][nbibler])
  * Add HTML response body on redirect
  * Set `Content-Type` header on redirect ([Jon Wood][jellybob])
  * Improve documentation ([Peter Baker][finack])

## 0.0.3 (2011-02-09)

  * Allow `env` to be passed to the optional block ([Tyler Hunt][tylerhunt])

## 0.0.2 (2010-11-18)

  * Move `CanonicalHost` into `Rack` namespace ([Tyler Hunt][tylerhunt])

## 0.0.1 (2009-11-04)

  * Initial release ([Tyler Hunt][tylerhunt])

[finack]: http://github.com/finack
[firedev]: http://github.com/firedev
[jcarbo]: http://github.com/jcarbo
[jellybob]: http://github.com/jellybob
[jschuur]: http://github.com/jschuur
[nbibler]: http://github.com/nbibler
[rubymaverick]: http://github.com/ericallam
[tma]: http://github.com/tma
[tylerhunt]: http://github.com/tylerhunt
[zoso10]: http://github.com/zoso10
