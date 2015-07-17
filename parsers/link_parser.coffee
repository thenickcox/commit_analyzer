#
# Modules
#

request = require('urllib-sync').request
path    = require('path')
fs      = require('fs')
marked  = require('marked')
_       = require('underscore')

#
# CONSTANTS
#

ERROR_CODE_RANGE_START = 400


RegExplorer =
  link: /(https?:\/\/?)([\da-z\.-]+\.[a-z\.]{2,6}[\/\w\-].*?)"/

LinkParser =
  linkMatches: []
  parse: (file, failures) ->
    console.log "Parsing links...\n\n\n"

    output = fs.readFileSync file.fullPath, 'utf-8'
    markdown = marked(output).split("\n")

    _.each markdown, (line) =>
      line = line.replace(/&amp;/g, '&')
      linkMatch = RegExplorer.link.exec(line)
      @linkMatches.push linkMatch[0].slice(0,-1) if linkMatch

    @validateLinks(file.fullPath, failures)

  validateLinks: (file, failures, deferred) ->
    _.each @linkMatches, (link) => @validateLink(link, file, failures)

  validateLink: (link, file, failures) ->
    try
      res = request(link)
      status = res.status
      @logError(link, null, status, file, failures) if status >= ERROR_CODE_RANGE_START
    catch error
      @logError(link, error.stack.slice(0, 100), null, file, failures)

  logError: (link, status, errorMsg, file, failures) ->
    extraMsg = if status then "response #{status}." else "error '#{errorMsg}'."
    console.log 'Build failed!'
    console.log "Reaching '#{link}' failed for the following reason: #{extraMsg}"
    console.log "Link referenced in '#{file}'\n"
    failures.push link

module.exports = LinkParser
