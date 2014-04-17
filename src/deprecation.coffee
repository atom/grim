module.exports =
class Deprecation
  @generateStack: ->
    originalPrepareStackTrace = Error.prepareStackTrace
    Error.prepareStackTrace = (error, stack) -> stack
    error = new Error()
    Error.captureStackTrace(error)
    stack = error.stack[2..] # Force prepare the stack https://code.google.com/p/v8/wiki/JavaScriptStackTraceApi
    Error.prepareStackTrace = originalPrepareStackTrace
    stack

  @getMethodNameFromCallsite: (callsite) ->
    if callsite.isToplevel()
      callsite.getFunctionName()
    else
      if callsite.isConstructor()
        "new #{callsite.getFunctionName()}"
      else
        "#{callsite.getTypeName()}.#{callsite.getMethodName() or callsite.getFunctionName()}"

  constructor: (@message) ->
    @count = 0
    @stacks = []

  getMethodNameFromCallsite: (callsite) ->
    Deprecation.getMethodNameFromCallsite(callsite)

  getLocationFromCallsite: (callsite) ->
    if callsite.isNative()
      "native"
    if callsite.isEval()
      "eval at #{@getLocationFromCallsite(callsite.getEvalOrigin())}"
    else
      "#{callsite.getFileName()}:#{callsite.getLineNumber()}:#{callsite.getColumnNumber}"

  getMethodName: ->
    @methodName

  getMessage: ->
    @message

  getStacks: ->
    @stacks

  getCount: ->
    @count

  addStack: (stack) ->
    @methodName = @getMethodNameFromCallsite(stack[0]) unless @methodName?
    stack = @parseStack(stack)
    console.log stack
    @stacks.push(stack) if @isStackUnique(stack)
    @count++

  parseStack: (stack) ->
    stack.map (callsite) =>
      methodName: @getMethodNameFromCallsite(callsite)
      location: @getLocationFromCallsite(callsite)
      fileName: callsite.getFileName()

  isStackUnique: (stack) ->
    stacks = @stacks.filter (s) ->
      return false unless s.length is stack.length

      for {methodName, location}, i in s
        callsite = stack[i]
        return false unless methodName == callsite.methodName and location == callsite.location

      true

    stacks.length == 0
