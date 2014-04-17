grim = require '../src/grim'

describe "Grim", ->
  afterEach ->
    grim.clearLog()

  describe "a deprecated constructor method", ->
    it "logs a warning", ->
      class Cow
        constructor: -> grim.deprecate("Use new Goat instead.")

      new Cow()

      expect(grim.getLog().length).toBe(1)
      logEntry = grim.getLog()[0]
      expect(logEntry).toBeDefined()
      expect(logEntry.getMessage()).toBe 'Use new Goat instead.'
      expect(logEntry.getCallCount()).toBe 1
      expect(logEntry.getStacks().length).toBe 1

  describe "a deprecated class method", ->
    it "logs a warning", ->
      class Cow
        @moo: -> grim.deprecate("Use Cow.say instead.")

      Cow.moo()

      expect(grim.getLog().length).toBe(1)
      logEntry = grim.getLog()[0]
      expect(logEntry).toBeDefined()
      expect(logEntry.getMessage()).toBe 'Use Cow.say instead.'
      expect(logEntry.getCallCount()).toBe 1
      expect(logEntry.getStacks().length).toBe 1

  describe "a deprecated class instance method", ->
    it "logs a warning", ->
      class Cow
        moo: -> grim.deprecate("Use Cow::say instead.")

      new Cow().moo()

      expect(grim.getLog().length).toBe(1)
      logEntry = grim.getLog()[0]
      expect(logEntry).toBeDefined()
      expect(logEntry.getMessage()).toBe 'Use Cow::say instead.'
      expect(logEntry.getCallCount()).toBe 1
      expect(logEntry.getStacks().length).toBe 1

  describe "a deprecated function", ->
    it "logs a warning", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")
      suchFunction()

      expect(grim.getLog().length).toBe(1)
      logEntry = grim.getLog()[0]
      expect(logEntry).toBeDefined()
      expect(logEntry.getMessage()).toBe 'Use soWow instead.'
      expect(logEntry.getCallCount()).toBe 1
      expect(logEntry.getStacks().length).toBe 1

  describe "when a deprecated function is called more than once", ->
    it "increments the count and appends the new stack trace", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")

      suchFunction()
      expect(grim.getLog().length).toBe(1)
      logEntry = grim.getLog()[0]
      expect(logEntry.getCallCount()).toBe 1
      expect(logEntry.getStacks().length).toBe 1

      suchFunction()
      expect(grim.getLog().length).toBe(1)
      logEntry = grim.getLog()[0]
      expect(logEntry.getCallCount()).toBe 2
      expect(logEntry.getStacks().length).toBe 2

  it "calls console.warn when .logDeprecationWarnings is called", ->
    spyOn(console, "warn")
    suchFunction = -> grim.deprecate("Use soWow instead.")
    suchFunction()

    expect(console.warn).not.toHaveBeenCalled()
    grim.logDeprecationWarnings()
    expect(console.warn).toHaveBeenCalled()

  it "emits the 'updated' event when a new deprecation error is logged", ->
    updatedHandler = jasmine.createSpy("updated")
    grim.on 'updated', updatedHandler
    grim.deprecate("Something deprecated was called.")

    expect(updatedHandler).toHaveBeenCalled()
