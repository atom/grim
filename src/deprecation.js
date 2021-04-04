/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const SourceMapCache = {}

module.exports =
class Deprecation {
  static getFunctionNameFromCallsite(callsite) {}

  static deserialize({message, fileName, lineNumber, stacks}) {
    const deprecation = new Deprecation(message, fileName, lineNumber);
    for (let stack of stacks) { deprecation.addStack(stack, stack.metadata); }
    return deprecation;
  }

  constructor(message, fileName, lineNumber) {
    this.message = message;
    this.fileName = fileName;
    this.lineNumber = lineNumber;
    this.callCount = 0;
    this.stackCount = 0;
    this.stacks = {};
    this.stackCallCounts = {};
  }

  getFunctionNameFromCallsite(callsite) {
    if (callsite.functionName != null) { return callsite.functionName; }

    if (callsite.isToplevel()) {
      let left;
      return (left = callsite.getFunctionName()) != null ? left : '<unknown>';
    } else {
      if (callsite.isConstructor()) {
        return `new ${callsite.getFunctionName()}`;
      } else if (callsite.getMethodName() && !callsite.getFunctionName()) {
        return callsite.getMethodName();
      } else {
        let left1, left2;
        return `${callsite.getTypeName()}.${(left1 = (left2 = callsite.getMethodName()) != null ? left2 : callsite.getFunctionName()) != null ? left1 : '<anonymous>'}`;
      }
    }
  }

  getLocationFromCallsite(callsite) {
    if (callsite == null) { return "unknown"; }
    if (callsite.location != null) { return callsite.location; }

    if (callsite.isNative()) {
      return "native";
    } else if (callsite.isEval()) {
      return `eval at ${this.getLocationFromCallsite(callsite.getEvalOrigin())}`;
    } else {
      const fileName = callsite.getFileName();
      const line = callsite.getLineNumber();
      const column = callsite.getColumnNumber();
      return `${fileName}:${line}:${column}`;
    }
  }

  getFileNameFromCallSite(callsite) {
    return callsite.fileName != null ? callsite.fileName : callsite.getFileName();
  }

  getOriginName() {
    return this.originName;
  }

  getMessage() {
    return this.message;
  }

  getStacks() {
    const parsedStacks = [];
    for (let location in this.stacks) {
      const stack = this.stacks[location];
      const parsedStack = this.parseStack(stack);
      parsedStack.callCount = this.stackCallCounts[location];
      parsedStack.metadata = stack.metadata;
      parsedStacks.push(parsedStack);
    }
    return parsedStacks;
  }

  getStackCount() {
    return this.stackCount;
  }

  getCallCount() {
    return this.callCount;
  }

  addStack(stack, metadata) {
    if (this.originName == null) { this.originName = this.getFunctionNameFromCallsite(stack[0]); }
    if (this.fileName == null) { this.fileName = this.getFileNameFromCallSite(stack[0]); }
    if (this.lineNumber == null) { this.lineNumber = stack[0].getLineNumber?.(); }
    this.callCount++;

    stack.metadata = metadata;
    const callerLocation = this.getLocationFromCallsite(stack[1]);
    if (this.stacks[callerLocation] == null) {
      this.stacks[callerLocation] = stack;
      this.stackCount++;
    }
    if (this.stackCallCounts[callerLocation] == null) { this.stackCallCounts[callerLocation] = 0; }
    return this.stackCallCounts[callerLocation]++;
  }

  parseStack(stack) {
    return stack.map(callsite => {
      return {
        functionName: this.getFunctionNameFromCallsite(callsite),
        location: this.getLocationFromCallsite(callsite),
        fileName: this.getFileNameFromCallSite(callsite)
      };
    });
  }

  serialize() {
    return {
      message: this.getMessage(),
      lineNumber: this.lineNumber,
      fileName: this.fileName,
      stacks: this.getStacks()
    };
  }
};
