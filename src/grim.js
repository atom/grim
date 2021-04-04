/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Deprecation = require('./deprecation');

if (global.__grim__ == null) {
  const {Emitter} = require('event-kit');
  var grim = (global.__grim__ = {
    deprecations: {},
    emitter: new Emitter,
    includeDeprecatedAPIs: true,

    getDeprecations() {
      const deprecations = [];
      for (let fileName in grim.deprecations) {
        const deprecationsByLineNumber = grim.deprecations[fileName];
        for (let lineNumber in deprecationsByLineNumber) {
          const deprecationsByPackage = deprecationsByLineNumber[lineNumber];
          for (let packageName in deprecationsByPackage) {
            const deprecation = deprecationsByPackage[packageName];
            deprecations.push(deprecation);
          }
        }
      }
      return deprecations;
    },

    getDeprecationsLength() {
      return this.getDeprecations().length;
    },

    clearDeprecations() {
      grim.deprecations = {};
    },

    logDeprecations() {
      const deprecations = this.getDeprecations();
      deprecations.sort((a, b) => b.getCallCount() - a.getCallCount());

      console.warn("\nCalls to deprecated functions\n-----------------------------");
      for (let deprecation of deprecations) {
        console.warn(`(${deprecation.getCallCount()}) ${deprecation.getOriginName()} : ${deprecation.getMessage()}`, deprecation);
      }
    },

    deprecate(message, metadata) {
      // Capture a 5-deep stack trace
      let stack;
      const originalStackTraceLimit = Error.stackTraceLimit;
      try {
        let left;
        Error.stackTraceLimit = 7;
        const error = new Error;
        // Get an array of v8 CallSite objects
        stack = (left = error.getRawStack?.()) != null ? left : getRawStack(error);
        stack = stack.slice(1);
      } finally {
        Error.stackTraceLimit = originalStackTraceLimit;
      }

      // Find or create a deprecation for this site
      const deprecationSite = stack[0];
      const fileName = deprecationSite.getFileName();
      const lineNumber = deprecationSite.getLineNumber();
      const packageName = metadata?.packageName != null ? metadata?.packageName : "";
      if (grim.deprecations[fileName] == null) { grim.deprecations[fileName] = {}; }
      if (grim.deprecations[fileName][lineNumber] == null) { grim.deprecations[fileName][lineNumber] = {}; }
      if (grim.deprecations[fileName][lineNumber][packageName] == null) { grim.deprecations[fileName][lineNumber][packageName] = new Deprecation(message); }

      const deprecation = grim.deprecations[fileName][lineNumber][packageName];

      // Add the current stack trace to the deprecation
      deprecation.addStack(stack, metadata);
      grim.emitter.emit("updated", deprecation);
    },

    addSerializedDeprecation(serializedDeprecation) {
      let deprecation = Deprecation.deserialize(serializedDeprecation);
      const message = deprecation.getMessage();
      const {fileName, lineNumber} = deprecation;
      const stacks = deprecation.getStacks();
      const packageName = stacks[0]?.metadata?.packageName != null ? stacks[0]?.metadata?.packageName : "";

      if (grim.deprecations[fileName] == null) { grim.deprecations[fileName] = {}; }
      if (grim.deprecations[fileName][lineNumber] == null) { grim.deprecations[fileName][lineNumber] = {}; }
      if (grim.deprecations[fileName][lineNumber][packageName] == null) { grim.deprecations[fileName][lineNumber][packageName] = new Deprecation(message, fileName, lineNumber); }

      deprecation = grim.deprecations[fileName][lineNumber][packageName];
      for (let stack of stacks) { deprecation.addStack(stack, stack.metadata); }
      grim.emitter.emit("updated", deprecation);
    },

    on(eventName, callback) { return grim.emitter.on(eventName, callback); }
  });
}

var getRawStack = function(error) {
  const originalPrepareStackTrace = Error.prepareStackTrace;
  Error.prepareStackTrace = (error, stack) => stack;
  Error.captureStackTrace(error, getRawStack);
  const result = error.stack;
  Error.prepareStackTrace = originalPrepareStackTrace;
  return result;
};

module.exports = global.__grim__;
