"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.parse = void 0;

var _pandaGrammar = require("panda-grammar");

var _pandaParchment = require("panda-parchment");

var add, build, bump, command, compact, constraints, dependencies, diff, first, flag, list, major, minor, packages, parse, publish, refresh, remove, second, strip, text, update, verify, wild, ws;
exports.parse = parse;
ws = (0, _pandaGrammar.re)(/^\s+/);
text = _pandaGrammar.string;

strip = function (p) {
  return (0, _pandaGrammar.rule)(p, function ({
    value
  }) {
    var i, item, len, results;

    if ((0, _pandaParchment.isArray)(value)) {
      results = [];

      for (i = 0, len = value.length; i < len; i++) {
        item = value[i];

        if (!(0, _pandaParchment.isString)(item) || !/^\s+/.test(item)) {
          results.push(item);
        }
      }

      return results;
    } else {
      return value;
    }
  });
};

compact = function (p) {
  return (0, _pandaGrammar.rule)(p, function ({
    value
  }) {
    var i, item, len, results;
    results = [];

    for (i = 0, len = value.length; i < len; i++) {
      item = value[i];

      if (item != null) {
        results.push(item);
      }
    }

    return results;
  });
};

first = function (p) {
  return (0, _pandaGrammar.rule)(p, function ({
    value
  }) {
    return value[0];
  });
};

second = function (p) {
  return (0, _pandaGrammar.rule)(p, function ({
    value
  }) {
    return value[1];
  });
};

flag = function (p) {
  return (0, _pandaGrammar.rule)(p, function ({
    value
  }) {
    return {
      [value]: true
    };
  });
}; // verify command


dependencies = text("dependencies");
build = text("build");
constraints = text("constraints");
verify = compact((0, _pandaGrammar.all)(text("verify"), (0, _pandaGrammar.optional)(first(strip((0, _pandaGrammar.all)(ws, (0, _pandaGrammar.tag)("scope", (0, _pandaGrammar.any)(dependencies, build, constraints)))))))); // update command

wild = text("wild");
update = compact((0, _pandaGrammar.all)(text("update"), (0, _pandaGrammar.optional)(first(strip((0, _pandaGrammar.all)(ws, flag(wild))))))); // refresh command

refresh = (0, _pandaGrammar.all)(text("refresh")); // bump command

major = text("major");
minor = text("minor");
bump = compact((0, _pandaGrammar.all)(text("bump"), (0, _pandaGrammar.optional)(first(strip((0, _pandaGrammar.all)(ws, flag((0, _pandaGrammar.any)(major, minor)))))))); // publish command

publish = (0, _pandaGrammar.all)(text("publish")); // packages command

list = (0, _pandaGrammar.tag)("subcommand", text("list"));
add = (0, _pandaGrammar.tag)("subcommand", text("add"));
remove = (0, _pandaGrammar.tag)("subcommand", text("remove"));
diff = (0, _pandaGrammar.tag)("subcommand", text("diff"));
packages = strip((0, _pandaGrammar.all)(text("packages"), ws, (0, _pandaGrammar.any)(list, add, remove, diff))); // grammar

command = second(strip((0, _pandaGrammar.all)(text("tempo"), ws, (0, _pandaGrammar.any)(verify, update, refresh, bump, publish, packages))));
exports.parse = parse = (0, _pandaGrammar.grammar)(command);
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi9Vc2Vycy9keS9yZXBvcy9kYXNoa2l0ZS90ZW1wby9zcmMvcGFyc2UuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7Ozs7QUFDQTs7QUFFQTs7QUFGQSxJQUFBLEdBQUEsRUFBQSxLQUFBLEVBQUEsSUFBQSxFQUFBLE9BQUEsRUFBQSxPQUFBLEVBQUEsV0FBQSxFQUFBLFlBQUEsRUFBQSxJQUFBLEVBQUEsS0FBQSxFQUFBLElBQUEsRUFBQSxJQUFBLEVBQUEsS0FBQSxFQUFBLEtBQUEsRUFBQSxRQUFBLEVBQUEsS0FBQSxFQUFBLE9BQUEsRUFBQSxPQUFBLEVBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQSxLQUFBLEVBQUEsSUFBQSxFQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsSUFBQSxFQUFBLEVBQUE7O0FBSUEsRUFBQSxHQUFLLHNCQUFBLE1BQUEsQ0FBTDtBQUNBLElBQUEsR0FBTyxvQkFBUDs7QUFDQSxLQUFBLEdBQVEsVUFBQSxDQUFBLEVBQUE7U0FBTyx3QkFBQSxDQUFBLEVBQVEsVUFBQztBQUFELElBQUE7QUFBQyxHQUFELEVBQUE7QUFDdkIsUUFBQSxDQUFBLEVBQUEsSUFBQSxFQUFBLEdBQUEsRUFBQSxPQUFBOztBQUFFLFFBQUcsNkJBQUgsS0FBRyxDQUFILEVBQUE7QUFDRSxNQUFBLE9BQUEsR0FBQSxFQUFBOztBQUFBLFdBQUEsQ0FBQSxHQUFBLENBQUEsRUFBQSxHQUFBLEdBQUEsS0FBQSxDQUFBLE1BQUEsRUFBQSxDQUFBLEdBQUEsR0FBQSxFQUFBLENBQUEsRUFBQSxFQUFBOzs7WUFBNEIsQ0FBRSw4QkFBRixJQUFFLENBQUYsSUFBb0IsQ0FBRSxPQUFBLElBQUEsQ0FBRCxJQUFDLEMsRUFBRDt1QkFBakQsSTs7QUFBQTs7YUFERixPO0FBQUEsS0FBQSxNQUFBO2FBQUEsSzs7QUFEYSxHQUFBLEM7QUFBUCxDQUFSOztBQUtBLE9BQUEsR0FBVSxVQUFBLENBQUEsRUFBQTtTQUFPLHdCQUFBLENBQUEsRUFBUSxVQUFDO0FB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LElBQUEsRUFBQSxHQUFBLEVBQUEsTUFBQSxFQWpEN0MsSUFpRDZDLENBQTVCLENBQU4sQ0FBWCxDOztBQUdBLE9BQUEsR0FBVSxNQUFBLENBQU8sS0FBQSxDQUFNLHVCQUFLLElBQUEsQ0FBTCxPQUFLLENBQUwsRUFBQSxFQUFBLEVBQ3BCLHVCQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsT0FBQSxFQUFBLElBQUEsRUFBQSxPQUFBLEVBRE8sUUFDUCxDQURvQixDQUFOLENBQVAsQ0FBVjtBQUdBLGdCQUFBLEtBQUEsR0FBUSwyQkFBQSxPQUFBLENBQVIiLCJzb3VyY2VzQ29udGVudCI6WyJcbmltcG9ydCB7cmUsIHN0cmluZywgbGlzdCBhcyBfbGlzdCwgYmV0d2VlbiwgYWxsLCBhbnksIG1hbnksIG9wdGlvbmFsLFxuICB0YWcsIG1lcmdlLCBqb2luLCBydWxlLCBncmFtbWFyfSBmcm9tIFwicGFuZGEtZ3JhbW1hclwiXG5pbXBvcnQge2lzQXJyYXksIGlzU3RyaW5nfSBmcm9tIFwicGFuZGEtcGFyY2htZW50XCJcblxud3MgPSByZSAvXlxccysvXG50ZXh0ID0gc3RyaW5nXG5zdHJpcCA9IChwKSAtPiBydWxlIHAsICh7dmFsdWV9KSAtPlxuICBpZiBpc0FycmF5IHZhbHVlXG4gICAgaXRlbSBmb3IgaXRlbSBpbiB2YWx1ZSB3aGVuICEoaXNTdHJpbmcgaXRlbSkgfHwgISgvXlxccysvLnRlc3QgaXRlbSlcbiAgZWxzZSB2YWx1ZVxuXG5jb21wYWN0ID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+XG4gIGl0ZW0gZm9yIGl0ZW0gaW4gdmFsdWUgd2hlbiBpdGVtP1xuXG5maXJzdCA9IChwKSAtPiBydWxlIHAsICh7dmFsdWV9KSAtPiB2YWx1ZVswXVxuc2Vjb25kID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+IHZhbHVlWzFdXG5cbmZsYWcgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT4gW3ZhbHVlXTogdHJ1ZVxuXG4jIHZlcmlmeSBjb21tYW5kXG5kZXBlbmRlbmNpZXMgPSB0ZXh0IFwiZGVwZW5kZW5jaWVzXCJcbmJ1aWxkID0gdGV4dCBcImJ1aWxkXCJcbmNvbnN0cmFpbnRzID0gdGV4dCBcImNvbnN0cmFpbnRzXCJcbnZlcmlmeSA9IGNvbXBhY3QgYWxsICh0ZXh0IFwidmVyaWZ5XCIpLFxuICAob3B0aW9uYWwgZmlyc3Qgc3RyaXAgYWxsIHdzLFxuICAgICh0YWcgXCJzY29wZVwiLCAoYW55IGRlcGVuZGVuY2llcywgYnVpbGQsIGNvbnN0cmFpbnRzKSkpXG5cbiMgdXBkYXRlIGNvbW1hbmRcbndpbGQgPSB0ZXh0IFwid2lsZFwiXG51cGRhdGUgPSBjb21wYWN0IGFsbCAodGV4dCBcInVwZGF0ZVwiKSxcbiAgKG9wdGlvbmFsIGZpcnN0IHN0cmlwIGFsbCB3cywgZmxhZyB3aWxkKVxuXG4jIHJlZnJlc2ggY29tbWFuZFxucmVmcmVzaCA9IGFsbCB0ZXh0IFwicmVmcmVzaFwiXG5cbiMgYnVtcCBjb21tYW5kXG5tYWpvciA9IHRleHQgXCJtYWpvclwiXG5taW5vciA9IHRleHQgXCJtaW5vclwiXG5idW1wID0gY29tcGFjdCBhbGwgKHRleHQgXCJidW1wXCIpLFxuICAob3B0aW9uYWwgZmlyc3Qgc3RyaXAgYWxsIHdzLCAoZmxhZyBhbnkgbWFqb3IsIG1pbm9yKSlcblxuIyBwdWJsaXNoIGNvbW1hbmRcbnB1Ymxpc2ggPSBhbGwgdGV4dCBcInB1Ymxpc2hcIlxuXG4jIHBhY2thZ2VzIGNvbW1hbmRcbmxpc3QgPSB0YWcgXCJzdWJjb21tYW5kXCIsIHRleHQgXCJsaXN0XCJcbmFkZCA9IHRhZyBcInN1YmNvbW1hbmRcIiwgdGV4dCBcImFkZFwiXG5yZW1vdmUgPSB0YWcgXCJzdWJjb21tYW5kXCIsIHRleHQgXCJyZW1vdmVcIlxuZGlmZiA9IHRhZyBcInN1YmNvbW1hbmRcIiwgdGV4dCBcImRpZmZcIlxucGFja2FnZXMgPSBzdHJpcCBhbGwgKHRleHQgXCJwYWNrYWdlc1wiKSwgd3MsIChhbnkgbGlzdCwgYWRkLCByZW1vdmUsIGRpZmYpXG5cbiMgZ3JhbW1hclxuY29tbWFuZCA9IHNlY29uZCBzdHJpcCBhbGwgKHRleHQgXCJ0ZW1wb1wiKSwgd3MsXG4gIChhbnkgdmVyaWZ5LCB1cGRhdGUsIHJlZnJlc2gsIGJ1bXAsIHB1Ymxpc2gsIHBhY2thZ2VzKVxuXG5wYXJzZSA9IGdyYW1tYXIgY29tbWFuZFxuXG5leHBvcnQge3BhcnNlfVxuIl0sInNvdXJjZVJvb3QiOiIifQ==
//# sourceURL=/Users/dy/repos/dashkite/tempo/src/parse.coffee