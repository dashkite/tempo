"use strict";

var _assert = _interopRequireDefault(require("assert"));

var _parse = require("../src/parse");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var fail, pass;

pass = function (input, expected) {
  var command, options;
  [command, options] = (0, _parse.parse)(input);

  _assert.default.equal(command, expected.command);

  return _assert.default.deepEqual(options, expected.options);
};

fail = function (input) {
  return _assert.default.equal(void 0, (0, _parse.parse)(input));
};

pass("tempo publish", {
  command: "publish"
});
pass("tempo packages list", {
  command: "packages",
  options: {
    subcommand: "list"
  }
});
pass("tempo verify", {
  command: "verify"
});
pass("tempo verify build", {
  command: "verify",
  options: {
    scope: "build"
  }
});
pass("tempo update", {
  command: "update"
});
pass("tempo update wild", {
  command: "update",
  options: {
    wild: true
  }
});
pass("tempo refresh", {
  command: "refresh"
});
pass("tempo bump", {
  command: "bump"
});
pass("tempo bump major", {
  command: "bump",
  options: {
    major: true
  }
});
fail("tempo notacommand");
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi9Vc2Vycy9keS9yZXBvcy9kYXNoa2l0ZS90ZW1wby90ZXN0L2luZGV4LmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiOztBQUFBOztBQUNBOzs7O0FBREEsSUFBQSxJQUFBLEVBQUEsSUFBQTs7QUFHQSxJQUFBLEdBQU8sVUFBQSxLQUFBLEVBQUEsUUFBQSxFQUFBO0FBQ1AsTUFBQSxPQUFBLEVBQUEsT0FBQTtBQUFFLEdBQUEsT0FBQSxFQUFBLE9BQUEsSUFBcUIsa0JBQUEsS0FBQSxDQUFyQjs7QUFDQSxrQkFBQSxLQUFBLENBQUEsT0FBQSxFQUFzQixRQUFRLENBQTlCLE9BQUE7O1NBQ0EsZ0JBQUEsU0FBQSxDQUFBLE9BQUEsRUFBMEIsUUFBUSxDQUFsQyxPQUFBLEM7QUFISyxDQUFQOztBQUtBLElBQUEsR0FBTyxVQUFBLEtBQUEsRUFBQTtTQUNMLGdCQUFBLEtBQUEsQ0FBYSxLQUFiLENBQUEsRUFBd0Isa0JBQXhCLEtBQXdCLENBQXhCLEM7QUFESyxDQUFQOztBQUdBLElBQUEsQ0FBQSxlQUFBLEVBQXNCO0FBQUEsRUFBQSxPQUFBLEVBQVM7QUFBVCxDQUF0QixDQUFBO0FBQ0EsSUFBQSxDQUFBLHFCQUFBLEVBQ0U7QUFBQSxFQUFBLE9BQUEsRUFBQSxVQUFBO0FBQ0EsRUFBQSxPQUFBLEVBQVM7QUFBQSxJQUFBLFVBQUEsRUFBWTtBQUFaO0FBRFQsQ0FERixDQUFBO0FBSUEsSUFBQSxDQUFBLGNBQUEsRUFDRTtBQUFBLEVBQUEsT0FBQSxFQUFTO0FBQVQsQ0FERixDQUFBO0FBRUEsSUFBQSxDQUFBLG9CQUFBLEVBQ0U7QUFBQSxFQUFBLE9BQUEsRUFBQSxRQUFBO0FBQ0EsRUFBQSxPQUFBLEVBQVM7QUFBQSxJQUFBLEtBQUEsRUFBTztBQUFQO0FBRFQsQ0FERixDQUFBO0FBR0EsSUFBQSxDQUFBLGNBQUEsRUFDRTtBQUFBLEVBQUEsT0FBQSxFQUFTO0FBQVQsQ0FERixDQUFBO0FBRUEsSUFBQSxDQUFBLG1CQUFBLEVBQ0U7QUFBQSxFQUFBLE9BQUEsRUFBQSxRQUFBO0FBQ0EsRUFBQSxPQUFBLEVBQVM7QUFBQSxJQUFBLElBQUEsRUFBTTtBQUFOO0FBRFQsQ0FERixDQUFBO0FBR0EsSUFBQSxDQUFBLGVBQUEsRUFDRTtBQUFBLEVBQUEsT0FBQSxFQUFTO0FBQVQsQ0FERixDQUFBO0FBRUEsSUFBQSxDQUFBLFlBQUEsRUFDRTtBQUFBLEVBQUEsT0FBQSxFQUFTO0FBQVQsQ0FERixDQUFBO0FBRUEsSUFBQSxDQUFBLGtCQUFBLEVBQ0U7QUFBQSxFQUFBLE9BQUEsRUFBQSxNQUFBO0FBQ0EsRUFBQSxPQUFBLEVBQVM7QUFBQSxJQUFBLEtBQUEsRUFBTztBQUFQO0FBRFQsQ0FERixDQUFBO0FBR0EsSUFBQSxDQUFBLG1CQUFBLENBQUEiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgYXNzZXJ0IGZyb20gXCJhc3NlcnRcIlxuaW1wb3J0IHtwYXJzZX0gZnJvbSBcIi4uL3NyYy9wYXJzZVwiXG5cbnBhc3MgPSAoaW5wdXQsIGV4cGVjdGVkKSAtPlxuICBbY29tbWFuZCwgb3B0aW9uc10gPSBwYXJzZSBpbnB1dFxuICBhc3NlcnQuZXF1YWwgY29tbWFuZCwgZXhwZWN0ZWQuY29tbWFuZFxuICBhc3NlcnQuZGVlcEVxdWFsIG9wdGlvbnMsIGV4cGVjdGVkLm9wdGlvbnNcblxuZmFpbCA9IChpbnB1dCkgLT5cbiAgYXNzZXJ0LmVxdWFsIHVuZGVmaW5lZCwgcGFyc2UgaW5wdXRcblxucGFzcyBcInRlbXBvIHB1Ymxpc2hcIiwgY29tbWFuZDogXCJwdWJsaXNoXCJcbnBhc3MgXCJ0ZW1wbyBwYWNrYWdlcyBsaXN0XCIsXG4gIGNvbW1hbmQ6IFwicGFja2FnZXNcIixcbiAgb3B0aW9uczogc3ViY29tbWFuZDogXCJsaXN0XCJcblxucGFzcyBcInRlbXBvIHZlcmlmeVwiLFxuICBjb21tYW5kOiBcInZlcmlmeVwiXG5wYXNzIFwidGVtcG8gdmVyaWZ5IGJ1aWxkXCIsXG4gIGNvbW1hbmQ6IFwidmVyaWZ5XCJcbiAgb3B0aW9uczogc2NvcGU6IFwiYnVpbGRcIlxucGFzcyBcInRlbXBvIHVwZGF0ZVwiLFxuICBjb21tYW5kOiBcInVwZGF0ZVwiXG5wYXNzIFwidGVtcG8gdXBkYXRlIHdpbGRcIixcbiAgY29tbWFuZDogXCJ1cGRhdGVcIlxuICBvcHRpb25zOiB3aWxkOiB0cnVlXG5wYXNzIFwidGVtcG8gcmVmcmVzaFwiLFxuICBjb21tYW5kOiBcInJlZnJlc2hcIlxucGFzcyBcInRlbXBvIGJ1bXBcIixcbiAgY29tbWFuZDogXCJidW1wXCJcbnBhc3MgXCJ0ZW1wbyBidW1wIG1ham9yXCIsXG4gIGNvbW1hbmQ6IFwiYnVtcFwiXG4gIG9wdGlvbnM6IG1ham9yOiB0cnVlXG5mYWlsIFwidGVtcG8gbm90YWNvbW1hbmRcIlxuIl0sInNvdXJjZVJvb3QiOiIifQ==
//# sourceURL=/Users/dy/repos/dashkite/tempo/test/index.coffee