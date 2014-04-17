Deprecation = require '../src/deprecation'

describe "Deprecation", ->
  describe "when there are mutliple stacks", ->
    it "stores multiple unique stacks", ->
      stackOne = Deprecation.generateStack()
      stackTwo = Deprecation.generateStack()

      deprecation = new Deprecation("oh no!")
      deprecation.addStack(stackOne)
      deprecation.addStack(stackTwo)

      expect(deprecation.getCallCount()).toBe 2
      expect(deprecation.getStacks().length).toBe 2

    it "does not store equivalent stacks", ->
      stacks = []
      stacks.push(Deprecation.generateStack()) for i in [0..2]

      deprecation = new Deprecation("oh no!")
      deprecation.addStack(stacks[0])
      deprecation.addStack(stacks[1])

      expect(deprecation.getCallCount()).toBe 2
      expect(deprecation.getStacks().length).toBe 1
      expect(deprecation.getStacks()[0].callCount).toBe 2
