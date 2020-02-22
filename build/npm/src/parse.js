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

refresh = text("refresh"); // bump command

major = text("major");
minor = text("minor");
bump = compact((0, _pandaGrammar.all)(text("bump"), (0, _pandaGrammar.optional)(first(strip((0, _pandaGrammar.all)(ws, flag((0, _pandaGrammar.any)(major, minor)))))))); // publish command

publish = text("publish"); // packages command

list = (0, _pandaGrammar.tag)("subcommand", text("list"));
add = (0, _pandaGrammar.tag)("subcommand", text("add"));
remove = (0, _pandaGrammar.tag)("subcommand", text("remove"));
diff = (0, _pandaGrammar.tag)("subcommand", text("diff"));
packages = strip((0, _pandaGrammar.all)(text("packages"), ws, (0, _pandaGrammar.any)(list, add, remove, diff))); // grammar

command = second(strip((0, _pandaGrammar.all)(text("tempo"), ws, (0, _pandaGrammar.any)(verify, update, refresh, bump, publish, packages))));
exports.parse = parse = (0, _pandaGrammar.grammar)(command);
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi9Vc2Vycy9keS9yZXBvcy9kYXNoa2l0ZS90ZW1wby9zcmMvcGFyc2UuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7Ozs7QUFDQTs7QUFFQTs7QUFGQSxJQUFBLEdBQUEsRUFBQSxLQUFBLEVBQUEsSUFBQSxFQUFBLE9BQUEsRUFBQSxPQUFBLEVBQUEsV0FBQSxFQUFBLFlBQUEsRUFBQSxJQUFBLEVBQUEsS0FBQSxFQUFBLElBQUEsRUFBQSxJQUFBLEVBQUEsS0FBQSxFQUFBLEtBQUEsRUFBQSxRQUFBLEVBQUEsS0FBQSxFQUFBLE9BQUEsRUFBQSxPQUFBLEVBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQSxLQUFBLEVBQUEsSUFBQSxFQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsSUFBQSxFQUFBLEVBQUE7O0FBSUEsRUFBQSxHQUFLLHNCQUFBLE1BQUEsQ0FBTDtBQUNBLElBQUEsR0FBTyxvQkFBUDs7QUFDQSxLQUFBLEdBQVEsVUFBQSxDQUFBLEVBQUE7U0FBTyx3QkFBQSxDQUFBLEVBQVEsVUFBQztBQUFELElBQUE7QUFBQyxHQUFELEVBQUE7QUFDdkIsUUFBQSxDQUFBLEVBQUEsSUFBQSxFQUFBLEdBQUEsRUFBQSxPQUFBOztBQUFFLFFBQUcsNkJBQUgsS0FBRyxDQUFILEVBQUE7QUFDRSxNQUFBLE9BQUEsR0FBQSxFQUFBOztBQUFBLFdBQUEsQ0FBQSxHQUFBLENBQUEsRUFBQSxHQUFBLEdBQUEsS0FBQSxDQUFBLE1BQUEsRUFBQSxDQUFBLEdBQUEsR0FBQSxFQUFBLENBQUEsRUFBQSxFQUFBOzs7WUFBNEIsQ0FBRSw4QkFBRixJQUFFLENBQUYsSUFBb0IsQ0FBRSxPQUFBLElBQUEsQ0FBRCxJQUFDLEMsRUFBRDt1QkFBakQsSTs7QUFBQTs7YUFERixPO0FBQUEsS0FBQSxNQUFBO2FBQUEsSzs7QUFEYSxHQUFBLEM7QUFBUCxDQUFSOztBQUtBLE9BQUEsR0FBVSxVQUFBLENBQUEsRUFBQTtTQUFPLHdCQUFBLENBQUEsRUFBUSxVQUFDO0FB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QUFBLEVBbEQ3QyxJQWtENkMsQ0FBNUIsQ0FBTixDQUFYLEM7O0FBR0EsT0FBQSxHQUFVLE1BQUEsQ0FBTyxLQUFBLENBQU0sdUJBQUssSUFBQSxDQUFMLE9BQUssQ0FBTCxFQUFBLEVBQUEsRUFDcEIsdUJBQUEsTUFBQSxFQUFBLE1BQUEsRUFBQSxPQUFBLEVBQUEsSUFBQSxFQUFBLE9BQUEsRUFETyxRQUNQLENBRG9CLENBQU4sQ0FBUCxDQUFWO0FBR0EsZ0JBQUEsS0FBQSxHQUFRLDJCQUFBLE9BQUEsQ0FBUiIsInNvdXJjZXNDb250ZW50IjpbIlxuaW1wb3J0IHtyZSwgc3RyaW5nLCBsaXN0IGFzIF9saXN0LCBiZXR3ZWVuLCBhbGwsIGFueSwgbWFueSwgb3B0aW9uYWwsXG4gIHRhZywgbWVyZ2UsIGpvaW4sIHJ1bGUsIGdyYW1tYXJ9IGZyb20gXCJwYW5kYS1ncmFtbWFyXCJcbmltcG9ydCB7aXNBcnJheSwgaXNTdHJpbmd9IGZyb20gXCJwYW5kYS1wYXJjaG1lbnRcIlxuXG53cyA9IHJlIC9eXFxzKy9cbnRleHQgPSBzdHJpbmdcbnN0cmlwID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+XG4gIGlmIGlzQXJyYXkgdmFsdWVcbiAgICBpdGVtIGZvciBpdGVtIGluIHZhbHVlIHdoZW4gIShpc1N0cmluZyBpdGVtKSB8fCAhKC9eXFxzKy8udGVzdCBpdGVtKVxuICBlbHNlIHZhbHVlXG5cbmNvbXBhY3QgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT5cbiAgaXRlbSBmb3IgaXRlbSBpbiB2YWx1ZSB3aGVuIGl0ZW0/XG5cbmZpcnN0ID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+IHZhbHVlWzBdXG5zZWNvbmQgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT4gdmFsdWVbMV1cblxuZmxhZyA9IChwKSAtPiBydWxlIHAsICh7dmFsdWV9KSAtPiBbdmFsdWVdOiB0cnVlXG5cbiMgdmVyaWZ5IGNvbW1hbmRcbmRlcGVuZGVuY2llcyA9IHRleHQgXCJkZXBlbmRlbmNpZXNcIlxuYnVpbGQgPSB0ZXh0IFwiYnVpbGRcIlxuY29uc3RyYWludHMgPSB0ZXh0IFwiY29uc3RyYWludHNcIlxudmVyaWZ5ID0gY29tcGFjdCBhbGwgKHRleHQgXCJ2ZXJpZnlcIiksXG4gIChvcHRpb25hbCBmaXJzdCBzdHJpcCBhbGwgd3MsXG4gICAgKHRhZyBcInNjb3BlXCIsIChhbnkgZGVwZW5kZW5jaWVzLCBidWlsZCwgY29uc3RyYWludHMpKSlcblxuXG4jIHVwZGF0ZSBjb21tYW5kXG53aWxkID0gdGV4dCBcIndpbGRcIlxudXBkYXRlID0gY29tcGFjdCBhbGwgKHRleHQgXCJ1cGRhdGVcIiksXG4gIChvcHRpb25hbCBmaXJzdCBzdHJpcCBhbGwgd3MsIGZsYWcgd2lsZClcblxuIyByZWZyZXNoIGNvbW1hbmRcbnJlZnJlc2ggPSB0ZXh0IFwicmVmcmVzaFwiXG5cbiMgYnVtcCBjb21tYW5kXG5tYWpvciA9IHRleHQgXCJtYWpvclwiXG5taW5vciA9IHRleHQgXCJtaW5vclwiXG5idW1wID0gY29tcGFjdCBhbGwgKHRleHQgXCJidW1wXCIpLFxuICAob3B0aW9uYWwgZmlyc3Qgc3RyaXAgYWxsIHdzLCAoZmxhZyBhbnkgbWFqb3IsIG1pbm9yKSlcblxuIyBwdWJsaXNoIGNvbW1hbmRcbnB1Ymxpc2ggPSB0ZXh0IFwicHVibGlzaFwiXG5cbiMgcGFja2FnZXMgY29tbWFuZFxubGlzdCA9IHRhZyBcInN1YmNvbW1hbmRcIiwgdGV4dCBcImxpc3RcIlxuYWRkID0gdGFnIFwic3ViY29tbWFuZFwiLCB0ZXh0IFwiYWRkXCJcbnJlbW92ZSA9IHRhZyBcInN1YmNvbW1hbmRcIiwgdGV4dCBcInJlbW92ZVwiXG5kaWZmID0gdGFnIFwic3ViY29tbWFuZFwiLCB0ZXh0IFwiZGlmZlwiXG5wYWNrYWdlcyA9IHN0cmlwIGFsbCAodGV4dCBcInBhY2thZ2VzXCIpLCB3cywgKGFueSBsaXN0LCBhZGQsIHJlbW92ZSwgZGlmZilcblxuIyBncmFtbWFyXG5jb21tYW5kID0gc2Vjb25kIHN0cmlwIGFsbCAodGV4dCBcInRlbXBvXCIpLCB3cyxcbiAgKGFueSB2ZXJpZnksIHVwZGF0ZSwgcmVmcmVzaCwgYnVtcCwgcHVibGlzaCwgcGFja2FnZXMpXG5cbnBhcnNlID0gZ3JhbW1hciBjb21tYW5kXG5cbmV4cG9ydCB7cGFyc2V9XG4iXSwic291cmNlUm9vdCI6IiJ9
//# sourceURL=/Users/dy/repos/dashkite/tempo/src/parse.coffee