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

#parsers = [frontMatterParser, markdownParser, fileParser, linkParser]
parsers = [fileParser]

#
# Execution
#

# Uncomment for production files
#directoryFilters = ['!node_modules', '!Release Notes']
#fileFilters      = '*.md'

# Uncomment for test files
directoryFilters = ['Accounts & Users']
fileFilters      = 'creating-users.md'

readOpts =
  root: path.join(__dirname)
  fileFilter: fileFilters
  directoryFilter: directoryFilters


stream = readdirp(readOpts).on('data', (file) ->
  _.each parsers, (parser) ->
    parser.parse(file)
)
