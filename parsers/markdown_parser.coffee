#
# Modules
#

fs     = require('fs')
marked = require('marked')
_      = require('underscore')

App =
  failures: []

MarkdownParser =
  parse: (file, failed) ->
    console.log "."
    fs.readFile file.fullPath, 'utf-8', (err, data) ->
      try
        marked(data)
      catch error
        console.log e
        console.log "File '#{file.fullPath}' failed markdown parsing.\n"
        App.failures.push file.fullPath

    failed = if App.failures.length then true else false
    failed

module.exports = MarkdownParser
