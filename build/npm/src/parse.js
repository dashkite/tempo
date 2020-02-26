"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.parse = void 0;

var _pandaGrammar = require("panda-grammar");

var _pandaParchment = require("panda-parchment");

var _flatten, add, build, bump, command, compact, constraints, dependencies, diff, first, flag, flatten, list, log, major, minor, packages, parse, publish, refresh, rehearse, remove, reverse, second, strip, subcommands, text, update, verify, wild, ws;

exports.parse = parse;

log = function (label, p) {
  return (0, _pandaGrammar.rule)(p, function (result) {
    console.log({
      [label]: result
    });
    return result;
  });
};

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

        if (!(0, _pandaParchment.isString)(item) || !/^\s+$/.test(item)) {
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
}; // TODO why isn't this in parchment?


_flatten = function (ax) {
  var a, bx, i, len;
  bx = [];

  for (i = 0, len = ax.length; i < len; i++) {
    a = ax[i];

    if ((0, _pandaParchment.isArray)(a)) {
      bx.push(..._flatten(a));
    } else {
      bx.push(a);
    }
  }

  return bx;
};

flatten = function (p) {
  return (0, _pandaGrammar.rule)(p, function ({
    value
  }) {
    return _flatten(value);
  });
};

reverse = function (p) {
  return (0, _pandaGrammar.rule)(p, function ({
    value
  }) {
    return value.reverse();
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
packages = strip((0, _pandaGrammar.all)(text("packages"), ws, (0, _pandaGrammar.any)(list, add, remove, diff))); // all the subcommands

subcommands = (0, _pandaGrammar.any)(verify, update, refresh, bump, publish, packages); // rehearse command

rehearse = (0, _pandaGrammar.rule)(second(strip((0, _pandaGrammar.all)(text("rehearse"), ws, subcommands))), function ({
  value: [command, options]
}) {
  if (options == null) {
    options = {};
  }

  options.rehearse = true;
  return [command, options];
}); // grammar

command = second(strip((0, _pandaGrammar.all)(text("tempo"), ws, (0, _pandaGrammar.any)(subcommands, rehearse))));
exports.parse = parse = (0, _pandaGrammar.grammar)(command);
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi9Vc2Vycy9keS9yZXBvcy9kYXNoa2l0ZS90ZW1wby9zcmMvcGFyc2UuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7Ozs7QUFDQTs7QUFFQTs7QUFGQSxJQUFBLFFBQUEsRUFBQSxHQUFBLEVBQUEsS0FBQSxFQUFBLElBQUEsRUFBQSxPQUFBLEVBQUEsT0FBQSxFQUFBLFdBQUEsRUFBQSxZQUFBLEVBQUEsSUFBQSxFQUFBLEtBQUEsRUFBQSxJQUFBLEVBQUEsT0FBQSxFQUFBLElBQUEsRUFBQSxHQUFBLEVBQUEsS0FBQSxFQUFBLEtBQUEsRUFBQSxRQUFBLEVBQUEsS0FBQSxFQUFBLE9BQUEsRUFBQSxPQUFBLEVBQUEsUUFBQSxFQUFBLE1BQUEsRUFBQSxPQUFBLEVBQUEsTUFBQSxFQUFBLEtBQUEsRUFBQSxXQUFBLEVBQUEsSUFBQSxFQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsSUFBQSxFQUFBLEVBQUE7Ozs7QUFJQSxHQUFBLEdBQU0sVUFBQSxLQUFBLEVBQUEsQ0FBQSxFQUFBO1NBQ0osd0JBQUEsQ0FBQSxFQUFRLFVBQUEsTUFBQSxFQUFBO0FBQ04sSUFBQSxPQUFPLENBQVAsR0FBQSxDQUFZO0FBQUEsT0FBQSxLQUFBLEdBQVM7QUFBVCxLQUFaO1dBQ0EsTTtBQUZGLEdBQUEsQztBQURJLENBQU47O0FBS0EsRUFBQSxHQUFLLHNCQUFBLE1BQUEsQ0FBTDtBQUNBLElBQUEsR0FBTyxvQkFBUDs7QUFDQSxLQUFBLEdBQVEsVUFBQSxDQUFBLEVBQUE7U0FBTyx3QkFBQSxDQUFBLEVBQVEsVUFBQztBQUFELElBQUE7QUFBQyxHQUFELEVBQUE7QUFDdkIsUUFBQSxDQUFBLEVBQUEsSUFBQSxFQUFBLEdBQUEsRUFBQSxPQUFBOztBQUFFLFFBQUcsNkJBQUgsS0FBRyxDQUFILEVBQUE7QUFDRSxNQUFBLE9BQUEsR0FBQSxFQUFBOztBQUFBLFdBQUEsQ0FBQSxHQUFBLENBQUEsRUFBQSxHQUFBLEdBQUEsS0FBQSxDQUFBLE1BQUEsRUFBQSxD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LENBQU4sQ0FBWCxDOztBQUdBLFdBQUEsR0FBZSx1QkFBQSxNQUFBLEVBQUEsTUFBQSxFQUFBLE9BQUEsRUFBQSxJQUFBLEVBQUEsT0FBQSxFQXBFZixRQW9FZSxDQUFmLEM7O0FBR0EsUUFBQSxHQUFXLHdCQUFNLE1BQUEsQ0FBTyxLQUFBLENBQU0sdUJBQUssSUFBQSxDQUFMLFVBQUssQ0FBTCxFQUFBLEVBQUEsRUFBbkIsV0FBbUIsQ0FBTixDQUFQLENBQU4sRUFDVCxVQUFDO0FBQUMsRUFBQSxLQUFBLEVBQU8sQ0FBQSxPQUFBLEVBQUEsT0FBQTtBQUFSLENBQUQsRUFBQTs7QUFDRSxJQUFBLE9BQUEsR0FBVyxFQUFYOzs7QUFDQSxFQUFBLE9BQU8sQ0FBUCxRQUFBLEdBQW1CLElBQW5CO1NBQ0EsQ0FBQSxPQUFBLEVBQUEsT0FBQSxDO0FBM0VKLENBdUVXLENBQVgsQzs7QUFPQSxPQUFBLEdBQVUsTUFBQSxDQUFPLEtBQUEsQ0FBTSx1QkFBSyxJQUFBLENBQUwsT0FBSyxDQUFMLEVBQUEsRUFBQSxFQUF5Qix1QkFBQSxXQUFBLEVBQXRDLFFBQXNDLENBQXpCLENBQU4sQ0FBUCxDQUFWO0FBRUEsZ0JBQUEsS0FBQSxHQUFRLDJCQUFBLE9BQUEsQ0FBUiIsInNvdXJjZXNDb250ZW50IjpbIlxuaW1wb3J0IHtyZSwgc3RyaW5nLCBsaXN0IGFzIF9saXN0LCBiZXR3ZWVuLCBhbGwsIGFueSwgbWFueSwgb3B0aW9uYWwsXG4gIHRhZywgbWVyZ2UsIGpvaW4sIHJ1bGUsIGdyYW1tYXJ9IGZyb20gXCJwYW5kYS1ncmFtbWFyXCJcbmltcG9ydCB7aXNBcnJheSwgaXNTdHJpbmd9IGZyb20gXCJwYW5kYS1wYXJjaG1lbnRcIlxuXG5sb2cgPSAobGFiZWwsIHApIC0+XG4gIHJ1bGUgcCwgKHJlc3VsdCkgLT5cbiAgICBjb25zb2xlLmxvZyBbbGFiZWxdOiByZXN1bHRcbiAgICByZXN1bHRcblxud3MgPSByZSAvXlxccysvXG50ZXh0ID0gc3RyaW5nXG5zdHJpcCA9IChwKSAtPiBydWxlIHAsICh7dmFsdWV9KSAtPlxuICBpZiBpc0FycmF5IHZhbHVlXG4gICAgaXRlbSBmb3IgaXRlbSBpbiB2YWx1ZSB3aGVuICEoaXNTdHJpbmcgaXRlbSkgfHwgISgvXlxccyskLy50ZXN0IGl0ZW0pXG4gIGVsc2UgdmFsdWVcblxuY29tcGFjdCA9IChwKSAtPiBydWxlIHAsICh7dmFsdWV9KSAtPlxuICBpdGVtIGZvciBpdGVtIGluIHZhbHVlIHdoZW4gaXRlbT9cblxuZmlyc3QgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT4gdmFsdWVbMF1cbnNlY29uZCA9IChwKSAtPiBydWxlIHAsICh7dmFsdWV9KSAtPiB2YWx1ZVsxXVxuXG4jIFRPRE8gd2h5IGlzbid0IHRoaXMgaW4gcGFyY2htZW50P1xuX2ZsYXR0ZW4gPSAoYXgpIC0+XG4gIGJ4ID0gW11cbiAgZm9yIGEgaW4gYXhcbiAgICBpZiBpc0FycmF5IGEgdGhlbiBieC5wdXNoIChfZmxhdHRlbiBhKS4uLiBlbHNlIGJ4LnB1c2ggYVxuICBieFxuXG5mbGF0dGVuID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+IF9mbGF0dGVuIHZhbHVlXG5cbnJldmVyc2UgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT4gdmFsdWUucmV2ZXJzZSgpXG5cbmZsYWcgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT4gW3ZhbHVlXTogdHJ1ZVxuXG4jIHZlcmlmeSBjb21tYW5kXG5kZXBlbmRlbmNpZXMgPSB0ZXh0IFwiZGVwZW5kZW5jaWVzXCJcbmJ1aWxkID0gdGV4dCBcImJ1aWxkXCJcbmNvbnN0cmFpbnRzID0gdGV4dCBcImNvbnN0cmFpbnRzXCJcbnZlcmlmeSA9IGNvbXBhY3QgYWxsICh0ZXh0IFwidmVyaWZ5XCIpLFxuICAob3B0aW9uYWwgZmlyc3Qgc3RyaXAgYWxsIHdzLFxuICAgICh0YWcgXCJzY29wZVwiLCAoYW55IGRlcGVuZGVuY2llcywgYnVpbGQsIGNvbnN0cmFpbnRzKSkpXG5cbiMgdXBkYXRlIGNvbW1hbmRcbndpbGQgPSB0ZXh0IFwid2lsZFwiXG51cGRhdGUgPSBjb21wYWN0IGFsbCAodGV4dCBcInVwZGF0ZVwiKSxcbiAgKG9wdGlvbmFsIGZpcnN0IHN0cmlwIGFsbCB3cywgZmxhZyB3aWxkKVxuXG4jIHJlZnJlc2ggY29tbWFuZFxucmVmcmVzaCA9IGFsbCB0ZXh0IFwicmVmcmVzaFwiXG5cbiMgYnVtcCBjb21tYW5kXG5tYWpvciA9IHRleHQgXCJtYWpvclwiXG5taW5vciA9IHRleHQgXCJtaW5vclwiXG5idW1wID0gY29tcGFjdCBhbGwgKHRleHQgXCJidW1wXCIpLFxuICAob3B0aW9uYWwgZmlyc3Qgc3RyaXAgYWxsIHdzLCAoZmxhZyBhbnkgbWFqb3IsIG1pbm9yKSlcblxuIyBwdWJsaXNoIGNvbW1hbmRcbnB1Ymxpc2ggPSBhbGwgdGV4dCBcInB1Ymxpc2hcIlxuXG4jIHBhY2thZ2VzIGNvbW1hbmRcbmxpc3QgPSB0YWcgXCJzdWJjb21tYW5kXCIsIHRleHQgXCJsaXN0XCJcbmFkZCA9IHRhZyBcInN1YmNvbW1hbmRcIiwgdGV4dCBcImFkZFwiXG5yZW1vdmUgPSB0YWcgXCJzdWJjb21tYW5kXCIsIHRleHQgXCJyZW1vdmVcIlxuZGlmZiA9IHRhZyBcInN1YmNvbW1hbmRcIiwgdGV4dCBcImRpZmZcIlxucGFja2FnZXMgPSBzdHJpcCBhbGwgKHRleHQgXCJwYWNrYWdlc1wiKSwgd3MsIChhbnkgbGlzdCwgYWRkLCByZW1vdmUsIGRpZmYpXG5cbiMgYWxsIHRoZSBzdWJjb21tYW5kc1xuc3ViY29tbWFuZHMgPSAoYW55IHZlcmlmeSwgdXBkYXRlLCByZWZyZXNoLCBidW1wLCBwdWJsaXNoLCBwYWNrYWdlcylcblxuIyByZWhlYXJzZSBjb21tYW5kXG5yZWhlYXJzZSA9IHJ1bGUgKHNlY29uZCBzdHJpcCBhbGwgKHRleHQgXCJyZWhlYXJzZVwiKSwgd3MsIHN1YmNvbW1hbmRzKSxcbiAgKHt2YWx1ZTogW2NvbW1hbmQsIG9wdGlvbnNdfSkgLT5cbiAgICBvcHRpb25zID89IHt9XG4gICAgb3B0aW9ucy5yZWhlYXJzZSA9IHRydWVcbiAgICBbY29tbWFuZCwgb3B0aW9uc11cblxuIyBncmFtbWFyXG5jb21tYW5kID0gc2Vjb25kIHN0cmlwIGFsbCAodGV4dCBcInRlbXBvXCIpLCB3cywgKGFueSBzdWJjb21tYW5kcywgcmVoZWFyc2UpXG5cbnBhcnNlID0gZ3JhbW1hciBjb21tYW5kXG5cbmV4cG9ydCB7cGFyc2V9XG4iXSwic291cmNlUm9vdCI6IiJ9
//# sourceURL=/Users/dy/repos/dashkite/tempo/src/parse.coffee