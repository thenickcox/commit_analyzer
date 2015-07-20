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
  sameDirMarkdownLink:  /href="(?!http)(?!\/\/)(?!\.\.)(.*\.md)/
  otherDirMarkdownLink: /href="(?!http)(\.\..*?\.md)/
  relativeImageLink:    /.*"(\.\.\/images.*?\.png|jpg)/

FileParser =
  relativeImages: []

  sameDirMarkdowns:  []
  otherDirMarkdowns: []

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

      sameDirMarkdownFileMatch = RegExplorer.sameDirMarkdownLink.exec(line)
      otherDirMarkdownFileMatch = RegExplorer.otherDirMarkdownLink.exec(line)
      relativeImageFileMatch = RegExplorer.relativeImageLink.exec(line)

      @relativeImages.push relativeImageFileMatch[1] if relativeImageFileMatch
      @sameDirMarkdowns.push sameDirMarkdownFileMatch[1] if sameDirMarkdownFileMatch
      @otherDirMarkdowns.push otherDirMarkdownFileMatch[1] if otherDirMarkdownFileMatch

      @files = @relativeImages.concat(@sameDirMarkdowns, @otherDirMarkdowns)

    @checkFiles(@files, @currentPath, file.fullPath)

    failed = true if App.failures.length
    @relativeImages = @sameDirMarkdowns = @otherDirMarkdowns = []

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
