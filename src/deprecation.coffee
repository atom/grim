_ = require 'underscore-plus'

module.exports =
class Deprecation
  @generateStack: ->
    originalPrepareStackTrace = Error.prepareStackTrace
    Error.prepareStackTrace = (error, stack) -> stack
    error = new Error()
    Error.captureStackTrace(error)
    # Force prepareStackTrace to be called https://code.google.com/p/v8/wiki/JavaScriptStackTraceApi
    stack = error.stack[1..] # Don't include the callsite for this method
    Error.prepareStackTrace = originalPrepareStackTrace
    stack

  @getFunctionNameFromCallsite: (callsite) ->
    if callsite.isToplevel()
      callsite.getFunctionName() ? '<unknown>'
    else
      if callsite.isConstructor()
        "new #{callsite.getFunctionName()}"
      else if callsite.getMethodName() and not callsite.getFunctionName()
        callsite.getMethodName()
      else
        "#{callsite.getTypeName()}.#{callsite.getMethodName() ? callsite.getFunctionName() ? '<anonymous>'}"

  constructor: (@message) ->
    @callCount = 0
    @stacks = []

  getFunctionNameFromCallsite: (callsite) ->
    Deprecation.getFunctionNameFromCallsite(callsite)

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
    _.clone(@stacks)

  getCallCount: ->
    @callCount

  addStack: (stack) ->
    @originName = @getFunctionNameFromCallsite(stack[0]) unless @originName?
    stack = @parseStack(stack)
    if existingStack = @isStackUnique(stack)
      existingStack.callCount++
    else
      @stacks.push(stack)

    @callCount++

  parseStack: (stack) ->
    stack = stack.map (callsite) =>
      functionName: @getFunctionNameFromCallsite(callsite)
      location: @getLocationFromCallsite(callsite)
      fileName: callsite.getFileName()

    stack.callCount = 1
    stack

  isStackUnique: (stack) ->
    stacks = @stacks.filter (s) ->
      return false unless s.length is stack.length

      for {functionName, location}, i in s
        callsite = stack[i]
        return false unless functionName == callsite.functionName and location == callsite.location

      true

    stacks[0]
