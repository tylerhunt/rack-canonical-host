# Changelog

## Rack::CanonicalHost 0.0.7

  * Fix an issue handling URLs containing `|` characters

## Rack::CanonicalHost 0.0.6

  * Prevent redirect if the canonical host name is `nil`

## Rack::CanonicalHost 0.0.5

  * Rename `ignored_hosts` option to `ignore`

## Rack::CanonicalHost 0.0.4

  * Add option to ignored certain hosts ([Eric Allam][rubymaverick])
  * Add tests ([Nathaniel Bibler][nbibler])
  * Add HTML response body on redirect
  * Set `Content-Type` header on redirect ([Jon Wood][jellybob])

## Rack::CanonicalHost 0.0.3

  * Allow `env` to be passed to the optional block

## Rack::CanonicalHost 0.0.2

  * Move `CanonicalHost` into `Rack` namespace

## Rack::CanonicalHost 0.0.1

  * Initial release

[jellybob]: http://github.com/jellybob
[nbibler]: http://github.com/nbibler
[rubymaverick]: http://github.com/rubymaverick
