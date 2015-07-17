frontMatter = require('json-front-matter')
path        = require('path')
fs          = require('fs')
colors      = require('colors')
_           = require('underscore')

App =
  failures: []

requiredAttrs    = ['title', 'date', 'author']
ignoredFileNames = ['README.md', 'index.md']

isEmptyObject    = (obj) -> !Object.getOwnPropertyNames(obj).length
fileIsIgnored    = (fileName) ->
  if ignoredFileNames.indexOf(fileName) >= 0 then return true else return false

keys = (obj) -> Object.getOwnPropertyNames(obj)

FrontMatterParser =
  parse: (file, failed) ->
    process.stdout.write "."
    return if fileIsIgnored(file.name)

    output = frontMatter.parse fs.readFileSync(file.fullPath, 'utf-8')
    fileAttrs = _.keys output.attributes

    attrDiff    = _.difference requiredAttrs, fileAttrs
    missingAttr = _.intersection(attrDiff, requiredAttrs)
    if missingAttr.length
      console.log "\nFile '#{file.fullPath}' did not contain required attributes in the front-matter.".red
      console.log "Required attributres are #{requiredAttrs.join(', ')}. File was missing a value for the following attibute(s): #{missingAttr.join(', ')}.\n".red
      App.failures.push file.fullPath

    failed = true if App.failures.length
    failed


module.exports = FrontMatterParser
