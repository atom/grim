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
      callsite.getFunctionName()
    else
      if callsite.isConstructor()
        "new #{callsite.getFunctionName()}"
      else
        "#{callsite.getTypeName()}.#{callsite.getMethodName() or callsite.getFunctionName()}"

  constructor: (@message) ->
    @callCount = 0
    @stacks = []

  getFunctionNameFromCallsite: (callsite) ->
    Deprecation.getFunctionNameFromCallsite(callsite)

  getLocationFromCallsite: (callsite) ->
    if callsite.isNative()
      "native"
    if callsite.isEval()
      "eval at #{@getLocationFromCallsite(callsite.getEvalOrigin())}"
    else
      "#{callsite.getFileName()}:#{callsite.getLineNumber()}:#{callsite.getColumnNumber()}"

  getOriginName: ->
    @originName

  getMessage: ->
    @message

  getStacks: ->
    @stacks

  getCallCount: ->
    @callCount

  addStack: (stack) ->
    @originName = @getFunctionNameFromCallsite(stack[0]) unless @originName?
    stack = @parseStack(stack)
    @stacks.push(stack) if @isStackUnique(stack)
    @callCount++

  parseStack: (stack) ->
    stack = stack.map (callsite) =>
      methodName: @getFunctionNameFromCallsite(callsite)
      location: @getLocationFromCallsite(callsite)
      fileName: callsite.getFileName()

    stack

  isStackUnique: (stack) ->
    stacks = @stacks.filter (s) ->
      return false unless s.length is stack.length

      for {methodName, location}, i in s
        callsite = stack[i]
        return false unless methodName == callsite.methodName and location == callsite.location

      true

    stacks[0]
