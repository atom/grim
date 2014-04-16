_ = require 'underscore-plus'
{Emitter} = require 'emissary'
Deprecation = require './deprecation'

global.__grimlog__ = {}

grim =
  getLog: ->
    global.__grimlog__

  clearLog: ->
    global.__grimlog__ = {}

  logDeprecationWarnings: ->
    deprecations = []
    deprecations.push(deprecation) for method, deprecation of grim.getLog()
    deprecations.sort (a, b) -> b.getCount() - a.getCount()

    console.warn "\nCalls to deprecated functions\n-----------------------------"
    for deprecation in deprecations
      console.warn "(#{deprecation.getCount()}) #{deprecation.getMethodName()} : #{deprecation.getMessage()}", deprecation

  deprecate: (message) ->
    stack = Deprecation.generateStack()
    methodName = Deprecation.getMethodName(stack)
    deprecation = grim.getLog()[methodName] ?= new Deprecation(message)
    deprecation.addStack(stack)
    grim.emit("updated")

Emitter.extend(grim)
module.exports = grim
