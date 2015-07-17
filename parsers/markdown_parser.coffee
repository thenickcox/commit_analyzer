#
# Modules
#

fs     = require('fs')
marked = require('marked')

App =
  failures: []

MarkdownParser =
  parse: (file) ->
    fs.readFile file.fullPath, 'utf-8', (err, data) ->
      try
        marked(data)
      catch error
        console.log e
        console.log "File '#{file.fullPath}' failed markdown parsing.\n"
        App.failures.push file.fullPath

    return App.failures

module.exports = MarkdownParser
