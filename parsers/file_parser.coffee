#
# Modules
#

fs         = require('fs')
path       = require('path')
marked     = require('marked')
_          = require('underscore')

#
# CONSTANTS
#

BUILD_SUCCESS = 1
BUILD_FAILURE = 0

RegExplorer =
  sameDirMarkdownLink:  /href="(?!\.\.)(.*\.md)/
  otherDirMarkdownLink: /href="(\.\..*\.md)/
  relativeImageLink:    /.*"(\.\.\/images.*\.png|jpg)/

FileParser =
  relativeImages: []
  absoluteImages: []

  sameDirMarkdowns:  []
  otherDirMarkdowns: []

  currentPath: ''
  projectDir: path.join(__dirname, '..', '..')

  parse: (file) ->
    @currentPath = file.fullParentDir

    fs.readFile file.fullPath, 'utf-8', (err, data) =>
      markdown = marked(data, gfm: true, breaks: true).split("\n")
      _.each markdown, (line) =>

        sameDirMarkdownFileMatch = RegExplorer.sameDirMarkdownLink.exec(line)
        otherDirMarkdownFileMatch = RegExplorer.otherDirMarkdownLink.exec(line)
        relativeImageFileMatch = RegExplorer.relativeImageLink.exec(line)

        @sameDirMarkdowns.push sameDirMarkdownFileMatch[1] if sameDirMarkdownFileMatch
        @otherDirMarkdowns.push otherDirMarkdownFileMatch[1] if otherDirMarkdownFileMatch
        @relativeImages.push relativeImageFileMatch[1] if relativeImageFileMatch


      @checkRelativeImages(@relativeImages)
      @checkSameDirMarkdowns(@sameDirMarkdowns, @currentPath)
      @checkOtherDirMarkdowns(@otherDirMarkdowns, @currentPath)

    return BUILD_SUCCESS

  checkRelativeImages: (images) ->
    _.each images, (file) =>
      fs.open path.join(@projectDir, 'images', file), 'r', (err, _) =>
        @printErrorAndReturnFailure(file) if err

  checkSameDirMarkdowns: (files, curPath) ->
    _.each files, (file) =>
      fs.open path.join(curPath, file), 'r', (err, _) =>
        @printErrorAndReturnFailure(file) if err

  checkOtherDirMarkdowns: (files, curPath) ->
    _.each files, (file) =>
      resolvedPath = path.resolve(curPath, file)
      fs.open resolvedPath, 'r', (err, _) =>
        @printErrorAndReturnFailure(resolvedPath) if err

  printErrorAndReturnFailure: (file) ->
    console.log 'Build failed!'
    console.log "File '#{file}' not found in this repository"
    return BUILD_FAILURE


module.exports = FileParser
