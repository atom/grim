grim = require '../src/grim'

describe "Grim", ->
  afterEach ->
    grim.clearLog()

  describe "a deprecated class method", ->
    it "logs a warning", ->
      class Cow
        @moo: -> grim.deprecate("Use Cow.say instead.")

      Cow.moo()

      expect(Object.keys(grim.getLog()).length).toBe(1)
      logEntry = grim.getLog()['Function.Cow.moo']
      expect(logEntry).toBeDefined()
      expect(logEntry.message).toBe 'Use Cow.say instead.'
      expect(logEntry.count).toBe 1
      expect(logEntry.stackTraces.length).toBe 1

  describe "a deprecated class instance method", ->
    it "logs a warning", ->
      class Cow
        moo: -> grim.deprecate("Use Cow::say instead.")

      new Cow().moo()

      expect(Object.keys(grim.getLog()).length).toBe(1)
      logEntry = grim.getLog()['Cow.moo']
      expect(logEntry).toBeDefined()
      expect(logEntry.message).toBe 'Use Cow::say instead.'
      expect(logEntry.count).toBe 1
      expect(logEntry.stackTraces.length).toBe 1

  describe "a deprecated function", ->
    it "logs a warning", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")
      suchFunction()

      expect(Object.keys(grim.getLog()).length).toBe(1)
      logEntry = grim.getLog()['suchFunction']
      expect(logEntry).toBeDefined()
      expect(logEntry.message).toBe 'Use soWow instead.'
      expect(logEntry.count).toBe 1
      expect(logEntry.stackTraces.length).toBe 1

  describe "when a deprecated function is called more than once", ->
    it "increments the count and appends the new stack trace", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")

      suchFunction()
      expect(Object.keys(grim.getLog()).length).toBe(1)
      logEntry = grim.getLog()['suchFunction']
      expect(logEntry.count).toBe 1
      expect(logEntry.stackTraces.length).toBe 1

      suchFunction()
      expect(Object.keys(grim.getLog()).length).toBe(1)
      logEntry = grim.getLog()['suchFunction']
      expect(logEntry.count).toBe 2
      expect(logEntry.stackTraces.length).toBe 2

  it "calls console.warn when .logDeprecationWarnings is called", ->
    spyOn(console, "warn")
    suchFunction = -> grim.deprecate("Use soWow instead.")
    suchFunction()

    expect(console.warn).not.toHaveBeenCalled()
    grim.logDeprecationWarnings()
    expect(console.warn).toHaveBeenCalled()
