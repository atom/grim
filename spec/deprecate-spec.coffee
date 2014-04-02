grim = require '../src/grim'

describe "Grim", ->
  afterEach ->
    grim.clearLog()

  describe "a deprecated class method", ->
    it "logs a warning", ->
      class Cow
        @moo: -> grim.deprecate("Use Cow.say instead.")

      Cow.moo()

      expect(Object.keys(grim.getLog())).toHaveLength(1)
      logEntry = grim.getLog()['Function.Cow.moo']
      expect(logEntry).toBeDefined()
      expect(logEntry.message).toBe 'Use Cow.say instead.'
      expect(logEntry.count).toBe 1
      expect(logEntry.stackTraces).toHaveLength 1

  describe "a deprecated class instance method", ->
    it "logs a warning", ->
      class Cow
        moo: -> grim.deprecate("Use Cow::say instead.")

      new Cow().moo()

      expect(Object.keys(grim.getLog())).toHaveLength(1)
      logEntry = grim.getLog()['Cow.moo']
      expect(logEntry).toBeDefined()
      expect(logEntry.message).toBe 'Use Cow::say instead.'
      expect(logEntry.count).toBe 1
      expect(logEntry.stackTraces).toHaveLength 1

  describe "a deprecated function", ->
    it "logs a warning", ->
      suchFunction = -> grim.deprecate("Use soWow instead.")
      suchFunction()

      expect(Object.keys(grim.getLog())).toHaveLength(1)
      logEntry = grim.getLog()['suchFunction']
      expect(logEntry).toBeDefined()
      expect(logEntry.message).toBe 'Use soWow instead.'
      expect(logEntry.count).toBe 1
      expect(logEntry.stackTraces).toHaveLength 1
