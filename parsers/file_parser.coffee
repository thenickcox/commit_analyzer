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
  otherDirMarkdownLink: /href="(\.\..*?\.md)/
  relativeImageLink:    /.*"(\.\.\/images.*?\.png|jpg)/

FileParser =
  relativeImages: []
  absoluteImages: []

  sameDirMarkdowns:  []
  otherDirMarkdowns: []

  currentPath: ''
  projectDir: path.join(__dirname, '..', '..')

  parse: (file) ->
    @currentPath = file.fullParentDir

    output = fs.readFileSync file.fullPath, 'utf-8'
    markdown = marked(output).split("\n")
    _.each markdown, (line) =>
      line = line.replace(/&amp;/g, '&')

      sameDirMarkdownFileMatch = RegExplorer.sameDirMarkdownLink.exec(line)
      otherDirMarkdownFileMatch = RegExplorer.otherDirMarkdownLink.exec(line)
      relativeImageFileMatch = RegExplorer.relativeImageLink.exec(line)

      @sameDirMarkdowns.push sameDirMarkdownFileMatch[1] if sameDirMarkdownFileMatch
      @otherDirMarkdowns.push otherDirMarkdownFileMatch[1] if otherDirMarkdownFileMatch
      @relativeImages.push relativeImageFileMatch[1] if relativeImageFileMatch


    @checkRelativeImages(@relativeImages, file.fullPath)
    @checkSameDirMarkdowns(@sameDirMarkdowns, @currentPath, file.fullPath)
    @checkOtherDirMarkdowns(@otherDirMarkdowns, @currentPath, file.fullPath)

    return BUILD_SUCCESS

  checkRelativeImages: (images, refFile) ->
    _.each images, (file) =>
      fs.open path.join(@projectDir, 'images', file), 'r', (err, _) =>
        @printErrorAndReturnFailure(file, refFile) if err

  checkSameDirMarkdowns: (files, curPath) ->
    _.each files, (file) =>
      fs.open path.join(curPath, file), 'r', (err, _) =>
        @printErrorAndReturnFailure(file) if err

  checkOtherDirMarkdowns: (files, curPath, refFile) ->
    _.each files, (file) =>
      resolvedPath = path.resolve(curPath, file)
      fs.open resolvedPath, 'r', (err, _) =>
        @printErrorAndReturnFailure(resolvedPath, refFile) if err

  printErrorAndReturnFailure: (file, refFile) ->
    console.log 'Build failed!'
    console.log "File '#{file}' not found in this repository (referenced from '#{refFile}')"
    return BUILD_FAILURE


module.exports = FileParser
