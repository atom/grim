_ = require 'underscore-plus'
{Emitter} = require 'emissary'
Deprecation = require './deprecation'

unless global.__grim__?
  grim = global.__grim__ =
    grimDeprecations: []

    maxDeprecationCallCount: ->
      250

    getDeprecations: ->
      _.clone(grim.grimDeprecations)

    getDeprecationsLength: ->
      grim.grimDeprecations.length

    clearDeprecations: ->
      grim.grimDeprecations = []

    logDeprecations: ->
      deprecations = grim.getDeprecations()
      deprecations.sort (a, b) -> b.getCallCount() - a.getCallCount()

      console.warn "\nCalls to deprecated functions\n-----------------------------"
      for deprecation in deprecations
        console.warn "(#{deprecation.getCallCount()}) #{deprecation.getOriginName()} : #{deprecation.getMessage()}", deprecation

    deprecate: (message) ->
      stack = Deprecation.generateStack()[1..] # Don't include the callsite for the grim.deprecate method
      methodName = Deprecation.getFunctionNameFromCallsite(stack[0])
      deprecations = grim.grimDeprecations
      unless deprecation = _.find(deprecations, (d) -> d.getOriginName() == methodName)
        deprecation = new Deprecation(message)
        grim.grimDeprecations.push(deprecation)

      if deprecation.getCallCount() < grim.maxDeprecationCallCount()
        deprecation.addStack(stack)
        grim.emit("updated", deprecation)

  Emitter.extend(grim)

module.exports = global.__grim__
