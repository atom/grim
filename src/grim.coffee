{Emitter} = require 'emissary'
Deprecation = require './deprecation'

unless global.__grim__?
  grim = global.__grim__ =
    deprecations: {}

    getDeprecations: ->
      deprecations = []
      for fileName, deprecationsByLineNumber of grim.deprecations
        for lineNumber, deprecation of deprecationsByLineNumber
          deprecations.push(deprecation)
      deprecations

    getDeprecationsLength: ->
      @getDeprecations().length

    clearDeprecations: ->
      grim.deprecations = {}
      return

    logDeprecations: ->
      deprecations = @getDeprecations()
      deprecations.sort (a, b) -> b.getCallCount() - a.getCallCount()

      console.warn "\nCalls to deprecated functions\n-----------------------------"
      for deprecation in deprecations
        console.warn "(#{deprecation.getCallCount()}) #{deprecation.getOriginName()} : #{deprecation.getMessage()}", deprecation
      return

    deprecate: (message, metadata) ->
      # Capture a 3-deep stack trace
      originalStackTraceLimit = Error.stackTraceLimit
      Error.stackTraceLimit = 3
      error = new Error
      Error.captureStackTrace(error)
      Error.stackTraceLimit = originalStackTraceLimit

      # Get an array of v8 CallSite objects
      originalPrepareStackTrace = Error.prepareStackTrace
      Error.prepareStackTrace = (error, stack) -> stack
      stack = error.stack[1..]
      Error.prepareStackTrace = originalPrepareStackTrace

      # Find or create a deprecation for this site
      deprecationSite = stack[0]
      fileName = deprecationSite.getFileName()
      lineNumber = deprecationSite.getLineNumber()
      grim.deprecations[fileName] ?= {}
      grim.deprecations[fileName][lineNumber] ?= new Deprecation(message)
      deprecation = grim.deprecations[fileName][lineNumber]

      # Add the current stack trace to the deprecation
      deprecation.addStack(stack, metadata)
      grim.emit("updated", deprecation)
      return

    addSerializedDeprecation: (serializedDeprecation) ->
      deprecation = Deprecation.deserialize(serializedDeprecation)
      message = deprecation.getMessage()
      {fileName, lineNumber} = deprecation
      stacks = deprecation.getStacks()

      grim.deprecations[fileName] ?= {}
      grim.deprecations[fileName][lineNumber] ?= new Deprecation(message, fileName, lineNumber)
      deprecation = grim.deprecations[fileName][lineNumber]
      deprecation.addStack(stack, stack.metadata) for stack in stacks
      grim.emit("updated", deprecation)
      return

  Emitter.extend(grim)

module.exports = global.__grim__
