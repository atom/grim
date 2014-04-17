_ = require 'underscore-plus'
{Emitter} = require 'emissary'
Deprecation = require './deprecation'

global.__grimlog__  = []

grim =
  getLog: ->
    _.clone(global.__grimlog__)

  clearLog: ->
    global.__grimlog__ = []

  logDeprecationWarnings: ->
    deprecations = grim.getLog()
    deprecations.sort (a, b) -> b.getCallCount() - a.getCallCount()

    console.warn "\nCalls to deprecated functions\n-----------------------------"
    for deprecation in deprecations
      console.warn "(#{deprecation.getCallCount()}) #{deprecation.getOriginName()} : #{deprecation.getMessage()}", deprecation

  deprecate: (message) ->
    stack = Deprecation.generateStack()[1..] # Don't include the callsite for the grim.deprecate method
    methodName = Deprecation.getFunctionNameFromCallsite(stack[0])
    unless deprecation = global.__grimlog__.find((d) -> d.getOriginName() == methodName)
      deprecation = new Deprecation(message)
      global.__grimlog__.push(deprecation)
    deprecation.addStack(stack)
    grim.emit("updated")

Emitter.extend(grim)
module.exports = grim
