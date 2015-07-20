#
# Modules
#

fs         = require('fs')
path       = require('path')
marked     = require('marked')
colors     = require('colors')
_          = require('underscore')


App =
  failures: []

RegExplorer =
  # not beginning with http or mailto or a ? (? bc `marked` parses some regex in their code as links…)
  # not beginning with "// (markdown shortcut link)
  # capture below
  #  any chars
  #  capture the anchor link (which is optional)
  #  capture the final double quote
  filePath: /href="(?!\?|http|mailto)(?!\/\/)((?!#)(.*?)((#.*?)?)("))/

FileParser =
  imagePaths: []
  markdownPaths:  []

  currentPath: ''

  files: []

  parse: (file, failed) ->
    App.failures = []
    @printWorkingIndicator()
    @currentPath = file.fullParentDir

    output = fs.readFileSync file.fullPath, 'utf-8'
    markdown = marked(output).split("\n")

    _.each markdown, (line) =>
      line = line.replace(/&amp;/g, '&')

      filePathMatch = RegExplorer.filePath.exec(line)
      @files.push filePathMatch[2] if filePathMatch

    @checkFiles(@files, @currentPath, file.fullPath)

    failed = true if App.failures.length
    @files = []

    failed

  checkFiles: (files, curPath, refFile) ->
    _.each files, (file) =>
      resolvedPath = path.resolve(curPath, file)
      try
        fd = fs.openSync resolvedPath, 'r'
        fs.closeSync(fd)
      catch err
        @printErrorAndReturnFailure(resolvedPath, refFile)

  printErrorAndReturnFailure: (file, refFile) ->
    console.log "\nFile '#{file}' not found. Is the path correct? (Referenced from '#{refFile}')".red
    App.failures.push file

  printWorkingIndicator: ->
    process.stdout.write "."


module.exports = FileParser
