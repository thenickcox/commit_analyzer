#
# Modules
#

readdirp     = require('readdirp')
path         = require('path')
es           = require('event-stream')
fs           = require('fs')
coffeescript = require('coffee-script')
_            = require('underscore')

#
# Parsers
#

frontMatterParser = require('./parsers/front_matter_parser')
markdownParser    = require('./parsers/markdown_parser')
fileParser        = require('./parsers/file_parser')
linkParser        = require('./parsers/link_parser')

Failures =
  failed: []

App =
  analyze: ->
    appFailures = Failures.failed
    readdirp @readOpts(), (file) =>
      _.each @parsers, (parser) =>
        failures = parser.parse(file, appFailures)
        appFailures.push failures
    , (err, res) ->
      failures = _.compact _.flatten appFailures
      failures = _.uniq failures
      if failures.length then process.exit(1) else process.exit(0)

  #parsers: [frontMatterParser, markdownParser, fileParser, linkParser]
  parsers: [linkParser, fileParser]

  # Uncomment for production files
  #directoryFilters: ['!node_modules', '!Release Notes']
  #fileFilters: '*.md'

  # Uncomment for test files
  directoryFilters: ['Accounts & Users']
  fileFilters: '*.md'

  readOpts: ->
    root: path.join(__dirname, '..')
    fileFilter: @fileFilters
    directoryFilter: @directoryFilters

App.analyze()
