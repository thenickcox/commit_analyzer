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

App =
  failed: false
  analyze: ->
    failed = false
    readdirp @readOpts(), (file) =>
      _.each @parsers, (parser) =>
        @failed = parser.parse(file, @failed)
    , (err, res) =>
      console.log "value of failed: #{@failed}"
      if @failed then process.exit(1) else process.exit(0)

  parsers: [frontMatterParser, markdownParser, fileParser, linkParser]
  #parsers: [fileParser]

  # Uncomment for production files
  directoryFilters: ['!node_modules', '!Release Notes']
  fileFilters: '*.md'

  # Uncomment for test files
  #directoryFilters: ['Accounts & Users']
  #fileFilters: '*.md'

  readOpts: ->
    root: path.join(__dirname, '..')
    fileFilter: @fileFilters
    directoryFilter: @directoryFilters

App.analyze()
