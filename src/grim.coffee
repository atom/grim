_ = require 'underscore-plus'
{Emitter} = require 'emissary'

global.__grimlog__ = {}

grim =
  getLog: ->
    global.__grimlog__

  clearLog: ->
    global.__grimlog__ = {}

  logDeprecationWarnings: ->
    warnings = []
    warnings.push [method, metadata] for method, metadata of grim.getLog()
    warnings.sort (a, b) -> b[1].count - a[1].count

    console.warn "\nCalls to deprecated functions\n-----------------------------"
    for [method, metadata] in warnings
      console.warn "(#{metadata.count}) #{method} : #{metadata.message}", metadata

  deprecate: (message) ->
    try
      throw new Error("Deprecated Method")
    catch e
      stackLines = e.stack.split("\n")
      [all, method] = stackLines[2].match(/^\s*at\s*(\S+)/)

    metadata = grim.getLog()[method] ?= {message: message, count: 0, stackTraces: []}
    metadata.count++
    metadata.stackTraces.push e.stack

    @emit("updated")

Emitter.extend(grim)
module.exports = grim
