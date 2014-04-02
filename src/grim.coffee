_ = require 'underscore-plus'

log = {}

module.exports =
  getLog: ->
    _.clone(log)

  clearLog: ->
    log = {}

  deprecate: (message) ->
    try
      throw new Error("Deprecated Method")
    catch e
      stackLines = e.stack.split("\n")
      [all, method] = stackLines[2].match(/^\s*at\s*(\S+)/)

    log[method] ?= {message: message, count: 0, stackTraces: []}
    log[method].count++
    log[method].stackTraces.push e.stack
