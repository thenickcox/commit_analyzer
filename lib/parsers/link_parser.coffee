#
# Modules
#

http   = require('http')
https  = require('https')
path   = require('path')
fs     = require('fs')
marked = require('marked')
_      = require('underscore')

#
# CONSTANTS
#

BUILD_SUCCESS = 1
BUILD_FAILURE = 0
ERROR_CODE_RANGE_START = 400


RegExplorer =
  link: /(https?:\/\/?)([\da-z\.-]+\.[a-z\.]{2,6}[\/\w\.-])(.*)"/
  https: /^https:\/\//

LinkParser =
  linkMatches: []
  parse: (file) ->
    fs.readFile file.fullPath, 'utf-8', (err, data) =>
      markdown = marked(data).split("\n")

      _.each markdown, (line) =>
        linkMatch = RegExplorer.link.exec(line)
        @linkMatches.push linkMatch[0].slice(0,-1) if linkMatch
      @validateLinks()

  validateLinks: ->
    _.each @linkMatches, (link) =>
      if RegExplorer.https.exec(link) then @validateHttps(link) else @validateHttp(link)
    BUILD_SUCCESS

  validateHttps: (link) ->
    https.get(link, (res, err) =>
      statusCode = res.statusCode
      @handleResponse(link, statusCode)
    ).on 'error', =>
      statusCode = 404
      @logError(link, statusCode)

  validateHttp: (link) ->
    http.get(link, (res, err) =>
      statusCode = res.statusCode
      @handleResponse(link, statusCode)
    ).on 'error', =>
      statusCode = 404
      @logError(link, statusCode)

  handleResponse: (statusCode, link) ->
    @logError(link, statusCode) if statusCode >= ERROR_CODE_RANGE_START

  logError: (link, statusCode) ->
    console.log 'Error!'
    console.log "#{link} got a server response of #{statusCode}."
    BUILD_FAILURE

module.exports = LinkParser
