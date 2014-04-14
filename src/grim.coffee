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
    originalPrepareStackTrace = Error.prepareStackTrace
    Error.prepareStackTrace = (error, stack) -> stack

    try
      throw new Error("Deprecated Method")
    catch e

    stack = e.stack # Forces Error.prepareStackTrace to be called https://code.google.com/p/v8/wiki/JavaScriptStackTraceApi
    Error.prepareStackTrace = originalPrepareStackTrace

    originCallsite = stack[1]
    method = originCallsite.getFunctionName()
    method = originCallsite.getTypeName() + "." + method if originCallsite.getTypeName() == "Function"

    metadata = grim.getLog()[method] ?= {message: message, count: 0, stacks: []}
    metadata.count++
    metadata.stacks.push stack

    grim.emit("updated")

Emitter.extend(grim)
module.exports = grim
