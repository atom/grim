grim = require '../src/grim'
Deprecation = require '../src/deprecation'

describe "Grim", ->
  beforeEach ->
    expect(grim.includeDeprecatedAPIs).toBe true

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
      expect(deprecation.getStackCount()).toBe 1

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
      expect(deprecation.getStackCount()).toBe 1

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
      expect(deprecation.getStackCount()).toBe 2
      expect(deprecation.getStacks()[0].callCount).toBe 1
      expect(deprecation.getStacks()[1].callCount).toBe 1

    it "does not store multiple stack traces for the same call site", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")
      suchFunction() for i in [1..3]

      expect(grim.getDeprecations().length).toBe(1)
      deprecation = grim.getDeprecations()[0]
      expect(deprecation.getCallCount()).toBe 3
      expect(deprecation.getStacks().length).toBe 1
      expect(deprecation.getStacks()[0].callCount).toBe 3

  describe "when metadata is provided as a second argument", ->
    it "associates the metadata with the stack trace", ->
      deprecatedFn = (metadata) -> grim.deprecate("It's deprecated.", metadata)

      deprecatedFn(foo: "bar")
      deprecatedFn(baz: "quux")

      expect(grim.getDeprecations().length).toBe 1
      [deprecation] = grim.getDeprecations()
      expect(deprecation.getStacks()[0].metadata).toEqual {foo: "bar"}
      expect(deprecation.getStacks()[1].metadata).toEqual {baz: "quux"}

    describe "when a packageName is defined", ->
      it "uses the packageName when grouping deprecations with the same call stack", ->
        deprecatedFn = (metadata) -> grim.deprecate("It's deprecated.", metadata)

        deprecatedFn(packageName: "bar")
        deprecatedFn(packageName: "bar")
        deprecatedFn(packageName: "quux")
        deprecatedFn(packageName: "quux")

        expect(grim.getDeprecations().length).toBe 2
        [deprecation1, deprecation2] = grim.getDeprecations()
        expect(deprecation1.callCount).toBe 2
        expect(deprecation1.getStacks()[0].metadata).toEqual {packageName: "bar"}
        expect(deprecation2.callCount).toBe 2
        expect(deprecation2.getStacks()[0].metadata).toEqual {packageName: "quux"}

        grim.addSerializedDeprecation(deprecation1.serialize())
        expect(grim.getDeprecationsLength()).toBe 2
        [deprecation1, deprecation2] = grim.getDeprecations()
        expect(deprecation1.callCount).toBe 4
        expect(deprecation1.getStacks()[0].metadata).toEqual {packageName: "bar"}
        expect(deprecation2.callCount).toBe 2
        expect(deprecation2.getStacks()[0].metadata).toEqual {packageName: "quux"}

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

  it "supports JSON serializing/deserializing", ->
    metadata = foo: 'bar'
    grim.deprecate('no good', metadata)

    [deprecation] = grim.getDeprecations()
    expect(deprecation.getCallCount()).toBe 1
    expect(grim.getDeprecationsLength()).toBe 1
    expect(deprecation.getStacks().length).toBe 1
    expect(deprecation.getStacks()[0].callCount).toBe 1

    deserialized = Deprecation.deserialize(deprecation.serialize())
    expect(deserialized.constructor).toBe deprecation.constructor
    expect(deserialized.getMessage()).toBe deprecation.getMessage()
    expect(deserialized.getOriginName()).toBe deprecation.getOriginName()
    expect(deserialized.getCallCount()).toBe deprecation.getCallCount()
    expect(deserialized.getStacks()).toEqual deprecation.getStacks()

    grim.addSerializedDeprecation(deprecation.serialize())
    expect(grim.getDeprecationsLength()).toBe 1
    expect(deprecation.getCallCount()).toBe 2
    expect(deprecation.getStacks().length).toBe 1
    expect(deprecation.getStacks()[0].callCount).toBe 2

    grim.clearDeprecations()
    grim.addSerializedDeprecation(deprecation.serialize())
    [deprecation] = grim.getDeprecations()
    expect(grim.getDeprecationsLength()).toBe 1
    expect(deprecation.getCallCount()).toBe 1
    expect(deprecation.getStacks().length).toBe 1
    expect(deprecation.getStacks()[0].callCount).toBe 1
    expect(deserialized.constructor).toBe deprecation.constructor
    expect(deserialized.getMessage()).toBe deprecation.getMessage()
    expect(deserialized.getOriginName()).toBe deprecation.getOriginName()
    expect(deserialized.getCallCount()).toBe deprecation.getCallCount()
    expect(deserialized.getStacks()).toEqual deprecation.getStacks()
