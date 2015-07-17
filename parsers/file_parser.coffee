#
# Modules
#

fs         = require('fs')
path       = require('path')
marked     = require('marked')
_          = require('underscore')


App =
  failures: []

RegExplorer =
  sameDirMarkdownLink:  /href="(?!http)(?!\.\.)(.*\.md)/
  otherDirMarkdownLink: /href="(?!http)(\.\..*?\.md)/
  relativeImageLink:    /.*"(\.\.\/images.*?\.png|jpg)/

FileParser =
  relativeImages: []
  absoluteImages: []

  sameDirMarkdowns:  []
  otherDirMarkdowns: []

  currentPath: ''
  projectDir: path.join(__dirname, '..', '..')

  parse: (file, failed) ->
    console.log "Parsing files...\n\n\n"
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


    @checkRelativeImages(@relativeImages, file.fullPath)
    @checkSameDirMarkdowns(@sameDirMarkdowns, @currentPath, file.fullPath)
    @checkOtherDirMarkdowns(@otherDirMarkdowns, @currentPath, file.fullPath)

    failed = if App.failures.length then true else false
    failed

  checkRelativeImages: (images, refFile) ->
    _.each images, (file) =>
      try
        fs.openSync path.join(@projectDir, 'images', file), 'r'
      catch err
        @printErrorAndReturnFailure(file, refFile)

  checkSameDirMarkdowns: (files, curPath, fullPath) ->
    _.each files, (file) =>
      try
        fs.openSync path.join(curPath, file), 'r'
      catch err
        @printErrorAndReturnFailure(file, fullPath)

  checkOtherDirMarkdowns: (files, curPath, refFile) ->
    _.each files, (file) =>
      resolvedPath = path.resolve(curPath, file)
      try
        fs.openSync resolvedPath, 'r'
      catch err
        @printErrorAndReturnFailure(resolvedPath, refFile)

  printErrorAndReturnFailure: (file, refFile) ->
    console.log 'Build failed!'
    console.log "File '#{file}' not found in this repository (referenced from '#{refFile}')\n"
    App.failures.push file


module.exports = FileParser
