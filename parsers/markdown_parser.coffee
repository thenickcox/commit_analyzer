#
# Modules
#

fs     = require('fs')
marked = require('marked')


MarkdownParser =
  parse: (file, failures) ->
    fs.readFile file.fullPath, 'utf-8', (err, data) ->
      try
        marked(data)
      catch error
        console.log e
        console.log "File '#{file.fullPath}' failed markdown parsing.\n"
        failures.push file.fullPath

    return failures

module.exports = MarkdownParser
