# Changelog

## 1.3.0 (2024-03-15)

  * Respond to invalid request URL with 400 ([Gareth Jones][G-Rath])
  * Drop support for Rack 1.5 ([Tyler Hunt][tylerhunt])

## 1.2.0 (2023-04-14)

  * Add support for Rack 3.0 ([Vinny Diehl][vinnydiehl])
  * Remove unneeded gem directives ([Olle Jonsson][olleolleolle])

## 1.1.0 (2021-11-10)

  * Support lambda/proc on `:if` and `:ignore` options ([Sean Huber][shuber])
  * Drop support for Ruby versions 2.3, 2.4, and 2.5 ([Tyler Hunt][tylerhunt])

## 1.0.0 (2020-04-16)

  * Use equality to determine string matches on `:if` and `:ignore`

## 0.2.3 (2017-04-20)

  * Add regexp support for `:ignore` option ([Daniel Searles][squaresurf])

## 0.2.2 (2016-05-17)

  * Add `:cache_control` option ([Pete Nicholls][Aupajo])

## 0.2.1 (2016-03-28)

  * Relax Rack dependency to allow for Rack 2 ([Tyler Ewing][zoso10])

## 0.2.0 (2016-03-28)

  * Normalize redirect URL to avoid XSS vulnerability ([Thomas Maurer][tma])
  * Remove `:force_ssl` option in favor of using [rack-ssl][rack-ssl]
    ([Nathaniel Bibler][nbibler])

[rack-ssl]: https://rubygems.org/gems/rack-ssl

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

[Aupajo]: https://github.com/Aupajo
[finack]: https://github.com/finack
[firedev]: https://github.com/firedev
[jcarbo]: https://github.com/jcarbo
[jellybob]: https://github.com/jellybob
[jschuur]: https://github.com/jschuur
[nbibler]: https://github.com/nbibler
[rubymaverick]: https://github.com/ericallam
[shuber]: https://github.com/shuber
[squaresurf]: httpss://github.com/squaresurf
[tma]: https://github.com/tma
[tylerhunt]: https://github.com/tylerhunt
[zoso10]: https://github.com/zoso10
[olleolleolle]: https://github.com/olleolleolle
[vinnydiehl]: https://github.com/vinnydiehl
[G-Rath]: https://github.com/G-Rath
