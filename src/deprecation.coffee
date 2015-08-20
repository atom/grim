SourceMapCache = {}

module.exports =
class Deprecation
  @getFunctionNameFromCallsite: (callsite) ->

  @deserialize: ({message, fileName, lineNumber, stacks}) ->
    deprecation = new Deprecation(message, fileName, lineNumber)
    deprecation.addStack(stack, stack.metadata) for stack in stacks
    deprecation

  constructor: (@message, @fileName, @lineNumber) ->
    @callCount = 0
    @stackCount = 0
    @stacks = {}
    @stackCallCounts = {}

  getFunctionNameFromCallsite: (callsite) ->
    return callsite.functionName if callsite.functionName?

    if callsite.isToplevel()
      callsite.getFunctionName() ? '<unknown>'
    else
      if callsite.isConstructor()
        "new #{callsite.getFunctionName()}"
      else if callsite.getMethodName() and not callsite.getFunctionName()
        callsite.getMethodName()
      else
        "#{callsite.getTypeName()}.#{callsite.getMethodName() ? callsite.getFunctionName() ? '<anonymous>'}"

  getLocationFromCallsite: (callsite) ->
    return callsite.location if callsite.location?

    if callsite.isNative()
      "native"
    else if callsite.isEval()
      "eval at #{@getLocationFromCallsite(callsite.getEvalOrigin())}"
    else
      fileName = callsite.getFileName()
      line = callsite.getLineNumber()
      column = callsite.getColumnNumber()
      "#{fileName}:#{line}:#{column}"

  getFileNameFromCallSite: (callsite) ->
    callsite.fileName ? callsite.getFileName()

  getOriginName: ->
    @originName

  getMessage: ->
    @message

  getStacks: ->
    parsedStacks = []
    for location, stack of @stacks
      parsedStack = @parseStack(stack)
      parsedStack.callCount = @stackCallCounts[location]
      parsedStack.metadata = stack.metadata
      parsedStacks.push(parsedStack)
    parsedStacks

  getStackCount: ->
    @stackCount

  getCallCount: ->
    @callCount

  addStack: (stack, metadata) ->
    @originName ?= @getFunctionNameFromCallsite(stack[0])
    @fileName ?= @getFileNameFromCallSite(stack[0])
    @lineNumber ?= stack[0].getLineNumber?()
    @callCount++

    stack.metadata = metadata
    callerLocation = @getLocationFromCallsite(stack[1])
    unless @stacks[callerLocation]?
      @stacks[callerLocation] = stack
      @stackCount++
    @stackCallCounts[callerLocation] ?= 0
    @stackCallCounts[callerLocation]++

  parseStack: (stack) ->
    stack.map (callsite) =>
      functionName: @getFunctionNameFromCallsite(callsite)
      location: @getLocationFromCallsite(callsite)
      fileName: @getFileNameFromCallSite(callsite)

  serialize: ->
    message: @getMessage()
    lineNumber: @lineNumber
    fileName: @fileName
    stacks: @getStacks()
