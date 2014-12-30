_ = require 'underscore-plus'

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
      "#{callsite.getFileName()}:#{callsite.getLineNumber()}:#{callsite.getColumnNumber()}"

  getOriginName: ->
    @originName

  getMessage: ->
    @message

  getStacks: ->
    parsedStacks = []
    for location, stack of @stacks
      parsedStack = @parseStack(stack)
      parsedStack.callCount = @stackCallCounts[location]
      parsedStacks.push(parsedStack)
    parsedStacks

  getCallCount: ->
    @callCount

  addStack: (stack) ->
    @originName ?= @getFunctionNameFromCallsite(stack[0])
    @callCount++

    callerLocation = @getLocationFromCallsite(stack[1])
    @stacks[callerLocation] ?= stack
    @stackCallCounts[callerLocation] ?= 0
    @stackCallCounts[callerLocation]++

  parseStack: (stack) ->
    stack.map (callsite) =>
      functionName: @getFunctionNameFromCallsite(callsite)
      location: @getLocationFromCallsite(callsite)
      fileName: callsite.getFileName()
