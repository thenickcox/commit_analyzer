frontMatter  = require('json-front-matter')
_            = require('underscore')

requiredAttrs    = ['title', 'date', 'author']
ignoredFileNames = ['README.md', 'index.md']

isEmptyObject    = (obj)  -> !Object.getOwnPropertyNames(obj).length
fileIsIgnored    = (fileName) ->
  if ignoredFileNames.indexOf(fileName) >= 0 then return true else return false

keys = (obj) -> Object.getOwnPropertyNames(obj)

#
# CONSTANTS
#

BUILD_SUCCESS = 1
BUILD_FAILURE = 0


FrontMatterParser =
  parse: (file) ->
    return if fileIsIgnored(file.name)
    console.log file.path
    frontMatter.parseFile file.path, (err, fileText) ->
      console.log 'file text:'
      console.log fileText

      if err or isEmptyObject(fileText.attributes)
        console.log 'build failure!'
        console.log "Error parsing JSON front-matter for file '#{file.fullPath}'\n"
        return BUILD_FAILURE

      attrDiff    = _.difference requiredAttrs, keys(fileText.attributes)
      missingAttr = _.intersection(attrDiff, requiredAttrs)
      if missingAttr.length
        console.log 'Build failure!'
        console.log "File '#{file.fullPath}' did not contain required attributes in the front-matter."
        console.log "Required attributres are #{requiredAttrs.join(', ')}. File was missing a value for the following attibute(s): #{missingAttr.join(', ')}.\n"
        return BUILD_FAILURE

    # console.log 'build success!'
    BUILD_SUCCESS

module.exports = FrontMatterParser
