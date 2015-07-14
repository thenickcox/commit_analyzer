#
# Modules
#

fs     = require('fs')
marked = require('marked')

#
# CONSTANTS
#

BUILD_SUCCESS = 1
BUILD_FAILURE = 0

MarkdownParser =
  parse: (file) ->
    fs.readFile file.fullPath, 'utf-8', (err, data) ->
      try
        marked(data)
      catch error
        console.log e
        console.log "File '#{file.fullPath}' failed markdown parsing."
        return BUILD_FAILURE

    BUILD_SUCCESS

module.exports = MarkdownParser
