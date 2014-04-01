{deprecate} = require '../src/grim'

class Cow
  @moo: ->
    deprecate("Use Cow.say() instead.")

  moo: ->
    deprecate("Use Cow::say() instead.")

describe "Grim", ->
  beforeEach ->
    spyOn(console, "warn")

  describe "a deprecated class method", ->
    it "logs a warning", ->
      Cow.moo()
      args = console.warn.mostRecentCall.args
      expect(args[0]).toMatch(/^Function.Cow.moo \([^\)]+\) is deprecated. Use Cow.say\(\) instead./)

  describe "a deprecated class instance method", ->
    it "logs a warning", ->
      new Cow().moo()
      args = console.warn.mostRecentCall.args
      expect(args[0]).toMatch(/^Cow.moo \([^\)]+\) is deprecated. Use Cow::say\(\) instead./)

  describe "a deprecated function", ->
    it "logs a warning", ->
      suchFunction = -> deprecate("Use soWow() instead.")
      suchFunction()
      args = console.warn.mostRecentCall.args
      expect(args[0]).toMatch(/^suchFunction \([^\)]+\) is deprecated. Use soWow\(\) instead./)
