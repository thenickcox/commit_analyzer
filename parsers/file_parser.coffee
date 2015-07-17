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
  sameDirMarkdownLink:  /href="(?!\.\.)(.*\.md)/
  otherDirMarkdownLink: /href="(\.\..*?\.md)/
  relativeImageLink:    /.*"(\.\.\/images.*?\.png|jpg)/

FileParser =
  relativeImages: []
  absoluteImages: []

  sameDirMarkdowns:  []
  otherDirMarkdowns: []

  currentPath: ''
  projectDir: path.join(__dirname, '..', '..')

  parse: (file, failures) ->
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


    @checkRelativeImages(@relativeImages, file.fullPath, failures)
    @checkSameDirMarkdowns(@sameDirMarkdowns, @currentPath, file.fullPath, failures)
    @checkOtherDirMarkdowns(@otherDirMarkdowns, @currentPath, file.fullPath, failures)

    failures = _.compact _.flatten failures
    failures = _.uniq failures
    failures

  checkRelativeImages: (images, refFile, failures) ->
    _.each images, (file) =>
      try
        fs.openSync path.join(@projectDir, 'images', file), 'r'
      catch err
        @printErrorAndReturnFailure(file, refFile, failures)

  checkSameDirMarkdowns: (files, curPath, fullPath, failures) ->
    _.each files, (file) =>
      try
        fs.openSync path.join(curPath, file), 'r'
      catch err
        @printErrorAndReturnFailure(file, fullPath, failures)

  checkOtherDirMarkdowns: (files, curPath, refFile, failures) ->
    _.each files, (file) =>
      resolvedPath = path.resolve(curPath, file)
      try
        fs.openSync resolvedPath, 'r'
      catch err
        @printErrorAndReturnFailure(resolvedPath, refFile, failures)

  printErrorAndReturnFailure: (file, refFile, failures) ->
    console.log 'Build failed!'
    console.log "File '#{file}' not found in this repository (referenced from '#{refFile}')\n"
    failures.push file


module.exports = FileParser
