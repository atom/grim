grim = require '../src/grim'

describe "Grim", ->
  afterEach ->
    grim.clearDeprecations()

  describe "a deprecated constructor method", ->
    it "logs a warning", ->
      class Cow
        constructor: -> grim.deprecate("Use new Goat instead.")

      new Cow()

      expect(grim.getDeprecations().length).toBe(1)
      deprecation = grim.getDeprecations()[0]
      expect(deprecation).toBeDefined()
      expect(deprecation.getMessage()).toBe 'Use new Goat instead.'
      expect(deprecation.getCallCount()).toBe 1
      expect(deprecation.getStacks().length).toBe 1

  describe "a deprecated class method", ->
    it "logs a warning", ->
      class Cow
        @moo: -> grim.deprecate("Use Cow.say instead.")

      Cow.moo()

      expect(grim.getDeprecations().length).toBe(1)
      deprecation = grim.getDeprecations()[0]
      expect(deprecation).toBeDefined()
      expect(deprecation.getMessage()).toBe 'Use Cow.say instead.'
      expect(deprecation.getCallCount()).toBe 1
      expect(deprecation.getStacks().length).toBe 1

  describe "a deprecated class instance method", ->
    it "logs a warning", ->
      class Cow
        moo: -> grim.deprecate("Use Cow::say instead.")

      new Cow().moo()

      expect(grim.getDeprecations().length).toBe(1)
      deprecation = grim.getDeprecations()[0]
      expect(deprecation).toBeDefined()
      expect(deprecation.getMessage()).toBe 'Use Cow::say instead.'
      expect(deprecation.getCallCount()).toBe 1
      expect(deprecation.getStacks().length).toBe 1

  describe "a deprecated function", ->
    it "logs a warning", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")
      suchFunction()

      expect(grim.getDeprecations().length).toBe(1)
      deprecation = grim.getDeprecations()[0]
      expect(deprecation).toBeDefined()
      expect(deprecation.getMessage()).toBe 'Use soWow instead.'
      expect(deprecation.getCallCount()).toBe 1
      expect(deprecation.getStacks().length).toBe 1

  describe "when a deprecated function is called more than once", ->
    it "increments the count and appends the new stack trace", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")

      suchFunction()
      expect(grim.getDeprecations().length).toBe(1)
      deprecation = grim.getDeprecations()[0]
      expect(deprecation.getCallCount()).toBe 1
      expect(deprecation.getStacks().length).toBe 1

      suchFunction()
      expect(grim.getDeprecations().length).toBe(1)
      deprecation = grim.getDeprecations()[0]
      expect(deprecation.getCallCount()).toBe 2
      expect(deprecation.getStacks().length).toBe 2

  it "calls console.warn when .logDeprecations is called", ->
    spyOn(console, "warn")
    suchFunction = -> grim.deprecate("Use soWow instead.")
    suchFunction()

    expect(console.warn).not.toHaveBeenCalled()
    grim.logDeprecations()
    expect(console.warn).toHaveBeenCalled()

  it "emits the 'updated' event when a new deprecation error is logged", ->
    updatedHandler = jasmine.createSpy("updated")
    grim.on 'updated', updatedHandler
    grim.deprecate("Something deprecated was called.")

    expect(updatedHandler).toHaveBeenCalled()
