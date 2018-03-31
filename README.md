# log4cr

Log4cr is a logging library modeled on Java's Log4J.
It builds on the `Logger` provided by Crystal's standard library and adds
hierarchical logging support.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  log4cr:
    github: thedrow484/log4cr
```

## Usage

```crystal
require "log4cr"
```

The main constructs in Log4cr are `Logger`s and `Appender`s.
At the moment, an `Appender` is an alias for the standard library's `Logger`.

To start logging, create a `Logger` with a category name and add an appender to it:

```crystal
logger = Log4cr::Logger.get "my.category"
logger.add_appender Log4cr::Appender.new STDOUT
logger.info "a message" # => logs "a message" to STDOUT (with a preamble)
```

By using the logging hierarchy, appenders can be added to a parent category for use
by all of its children:

```crystal
important_logger = Log4cr::Logger.get "my.important_logger"
unimportant_logger = Log4cr::Logger.get "my.unimportant_logger"
unimportant_logger.level = ::Logger::FATAL
Log4cr::Logger.get("my").add_appender Log4cr::Appender.new STDOUT
important_logger.info "important message" # => logs to STDOUT
unimportant_logger.info "unimportant message" # => no logging
```

All named categories have the "root" categories as their eventual parent.
The root logger can be used to add an appender to all loggers:

```crystal
some_logger = Log4cr::Logger.get "some_logger"
another_logger = Log4cr::Logger.get "another_logger"
Log4cr::Logger.root_logger.add_appender Log4cr::Appender.new STDOUT
some_logger.info "important message" # => logs to STDOUT
another_logger.info "unimportant message" # => logs to STDOUT
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/thedrow484/log4cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [thedrow484](https://github.com/thedrow484) William VanDyke - creator, maintainer
