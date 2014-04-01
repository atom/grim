exports.deprecate = (message) ->
  try
    throw new Error("Deprecated Method")
  catch e
    stackLines = e.stack.split("\n")
    method = stackLines[2].replace(/^\s*at\s*/, '')

  console.warn "#{method} is deprecated. #{message}", e.stack
