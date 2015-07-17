frontMatter = require('json-front-matter')
path        = require('path')
fs          = require('fs')
_           = require('underscore')

requiredAttrs    = ['title', 'date', 'author']
ignoredFileNames = ['README.md', 'index.md']

isEmptyObject    = (obj) -> !Object.getOwnPropertyNames(obj).length
fileIsIgnored    = (fileName) ->
  if ignoredFileNames.indexOf(fileName) >= 0 then return true else return false

keys = (obj) -> Object.getOwnPropertyNames(obj)

FrontMatterParser =
  parse: (file, failures) ->
    return if fileIsIgnored(file.name)

    output = frontMatter.parse fs.readFileSync(file.fullPath, 'utf-8')
    fileAttrs = _.keys output.attributes

    attrDiff    = _.difference requiredAttrs, fileAttrs
    missingAttr = _.intersection(attrDiff, requiredAttrs)
    if missingAttr.length
      console.log 'Build failure!'
      console.log "File '#{file.fullPath}' did not contain required attributes in the front-matter."
      console.log "Required attributres are #{requiredAttrs.join(', ')}. File was missing a value for the following attibute(s): #{missingAttr.join(', ')}.\n"
      failures.push file.fullPath

    failures = _.compact failures
    failures


module.exports = FrontMatterParser
