_ = require 'underscore-plus'
{convertLine} = require 'coffeestack'

SourceMapCache = {}

module.exports =
class Deprecation
  @getFunctionNameFromCallsite: (callsite) ->

  constructor: (@message) ->
    @callCount = 0
    @stacks = {}
    @stackCallCounts = {}

  getFunctionNameFromCallsite: (callsite) ->
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
    if callsite.isNative()
      "native"
    else if callsite.isEval()
      "eval at #{@getLocationFromCallsite(callsite.getEvalOrigin())}"
    else
      fileName = callsite.getFileName()
      line = callsite.getLineNumber()
      column = callsite.getColumnNumber()

      if /\.coffee$/.test(fileName)
        if converted = convertLine(fileName, line, column, SourceMapCache)
          {line, column} = converted

      "#{fileName}:#{line}:#{column}"

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

  getCallCount: ->
    @callCount

  addStack: (stack, metadata) ->
    @originName ?= @getFunctionNameFromCallsite(stack[0])
    @callCount++

    stack.metadata = metadata
    callerLocation = @getLocationFromCallsite(stack[1])
    @stacks[callerLocation] ?= stack
    @stackCallCounts[callerLocation] ?= 0
    @stackCallCounts[callerLocation]++

  parseStack: (stack) ->
    stack.map (callsite) =>
      functionName: @getFunctionNameFromCallsite(callsite)
      location: @getLocationFromCallsite(callsite)
      fileName: callsite.getFileName()
