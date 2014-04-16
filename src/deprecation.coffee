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

  @getMethodName: (stack) ->
    callsite = stack[0]
    if callsite.getTypeName() == "Window"
      callsite.getFunctionName()
    else
      if callsite.isConstructor()
        "new #{callsite.getFunctionName()}"
      else
        "#{callsite.getTypeName()}.#{callsite.getMethodName() or callsite.getFunctionName()}"

  constructor: (@message) ->
    @count = 0
    @stacks = []

  addStack: (stack) ->
    @methodName = Deprecation.getMethodName(stack) unless @methodName?
    @stacks.push(stack)
    @count++

  getMethodName: ->
    @methodName

  getMessage: ->
    @message

  getStacks: ->
    @stacks

  getCount: ->
    @count
