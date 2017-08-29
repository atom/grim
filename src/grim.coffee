Deprecation = require './deprecation'

unless global.__grim__?
  {Emitter} = require 'event-kit'
  grim = global.__grim__ =
    deprecations: {}
    emitter: new Emitter
    includeDeprecatedAPIs: true

    getDeprecations: ->
      deprecations = []
      for fileName, deprecationsByLineNumber of grim.deprecations
        for lineNumber, deprecationsByPackage of deprecationsByLineNumber
          for packageName, deprecation of deprecationsByPackage
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
      # Capture a 5-deep stack trace
      originalStackTraceLimit = Error.stackTraceLimit
      try
        Error.stackTraceLimit = 7
        error = new Error
        # Get an array of v8 CallSite objects
        stack = error.getRawStack?() ? getRawStack(error)
        stack = stack.slice(1)
      finally
        Error.stackTraceLimit = originalStackTraceLimit

      # Find or create a deprecation for this site
      deprecationSite = stack[0]
      fileName = deprecationSite.getFileName()
      lineNumber = deprecationSite.getLineNumber()
      packageName = metadata?.packageName ? ""
      grim.deprecations[fileName] ?= {}
      grim.deprecations[fileName][lineNumber] ?= {}
      grim.deprecations[fileName][lineNumber][packageName] ?= new Deprecation(message)

      deprecation = grim.deprecations[fileName][lineNumber][packageName]

      # Add the current stack trace to the deprecation
      deprecation.addStack(stack, metadata)
      @emitter.emit("updated", deprecation)
      return

    addSerializedDeprecation: (serializedDeprecation) ->
      deprecation = Deprecation.deserialize(serializedDeprecation)
      message = deprecation.getMessage()
      {fileName, lineNumber} = deprecation
      stacks = deprecation.getStacks()
      packageName = stacks[0]?.metadata?.packageName ? ""

      grim.deprecations[fileName] ?= {}
      grim.deprecations[fileName][lineNumber] ?= {}
      grim.deprecations[fileName][lineNumber][packageName] ?= new Deprecation(message, fileName, lineNumber)

      deprecation = grim.deprecations[fileName][lineNumber][packageName]
      deprecation.addStack(stack, stack.metadata) for stack in stacks
      @emitter.emit("updated", deprecation)
      return

    on: (eventName, callback) -> @emitter.on(eventName, callback)

getRawStack = (error) ->
  originalPrepareStackTrace = Error.prepareStackTrace
  Error.prepareStackTrace = (error, stack) -> stack
  Error.captureStackTrace(error, getRawStack)
  result = error.stack
  Error.prepareStackTrace = originalPrepareStackTrace
  result

module.exports = global.__grim__
