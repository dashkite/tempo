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

command = (0, _pandaGrammar.any)(subcommands, rehearse);
exports.parse = parse = (0, _pandaGrammar.grammar)(command);
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi9Vc2Vycy9keS9yZXBvcy9kYXNoa2l0ZS90ZW1wby9zcmMvcGFyc2UuY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7Ozs7Ozs7QUFDQTs7QUFFQTs7QUFGQSxJQUFBLFFBQUEsRUFBQSxHQUFBLEVBQUEsS0FBQSxFQUFBLElBQUEsRUFBQSxPQUFBLEVBQUEsT0FBQSxFQUFBLFdBQUEsRUFBQSxZQUFBLEVBQUEsSUFBQSxFQUFBLEtBQUEsRUFBQSxJQUFBLEVBQUEsT0FBQSxFQUFBLElBQUEsRUFBQSxHQUFBLEVBQUEsS0FBQSxFQUFBLEtBQUEsRUFBQSxRQUFBLEVBQUEsS0FBQSxFQUFBLE9BQUEsRUFBQSxPQUFBLEVBQUEsUUFBQSxFQUFBLE1BQUEsRUFBQSxPQUFBLEVBQUEsTUFBQSxFQUFBLEtBQUEsRUFBQSxXQUFBLEVBQUEsSUFBQSxFQUFBLE1BQUEsRUFBQSxNQUFBLEVBQUEsSUFBQSxFQUFBLEVBQUE7Ozs7QUFJQSxHQUFBLEdBQU0sVUFBQSxLQUFBLEVBQUEsQ0FBQSxFQUFBO1NBQ0osd0JBQUEsQ0FBQSxFQUFRLFVBQUEsTUFBQSxFQUFBO0FBQ04sSUFBQSxPQUFPLENBQVAsR0FBQSxDQUFZO0FBQUEsT0FBQSxLQUFBLEdBQVM7QUFBVCxLQUFaO1dBQ0EsTTtBQUZGLEdBQUEsQztBQURJLENBQU47O0FBS0EsRUFBQSxHQUFLLHNCQUFBLE1BQUEsQ0FBTDtBQUNBLElBQUEsR0FBTyxvQkFBUDs7QUFDQSxLQUFBLEdBQVEsVUFBQSxDQUFBLEVBQUE7U0FBTyx3QkFBQSxDQUFBLEVBQVEsVUFBQztBQUFELElBQUE7QUFBQyxHQUFELEVBQUE7QUFDdkIsUUFBQSxDQUFBLEVBQUEsSUFBQSxFQUFBLEdBQUEsRUFBQSxPQUFBOztBQUFFLFFBQUcsNkJBQUgsS0FBRyxDQUFILEVBQUE7QUFDRSxNQUFBLE9BQUEsR0FBQSxFQUFBOztBQUFBLFdBQUEsQ0FBQSxHQUFBLENBQUEsRUFBQSxHQUFBLEdBQUEsS0FBQSxDQUFBLE1BQUEsRUFBQSxD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LENBQU4sQ0FBWCxDOztBQUdBLFdBQUEsR0FBZSx1QkFBQSxNQUFBLEVBQUEsTUFBQSxFQUFBLE9BQUEsRUFBQSxJQUFBLEVBQUEsT0FBQSxFQXBFZixRQW9FZSxDQUFmLEM7O0FBR0EsUUFBQSxHQUFXLHdCQUFNLE1BQUEsQ0FBTyxLQUFBLENBQU0sdUJBQUssSUFBQSxDQUFMLFVBQUssQ0FBTCxFQUFBLEVBQUEsRUFBbkIsV0FBbUIsQ0FBTixDQUFQLENBQU4sRUFDVCxVQUFDO0FBQUMsRUFBQSxLQUFBLEVBQU8sQ0FBQSxPQUFBLEVBQUEsT0FBQTtBQUFSLENBQUQsRUFBQTs7QUFDRSxJQUFBLE9BQUEsR0FBVyxFQUFYOzs7QUFDQSxFQUFBLE9BQU8sQ0FBUCxRQUFBLEdBQW1CLElBQW5CO1NBQ0EsQ0FBQSxPQUFBLEVBQUEsT0FBQSxDO0FBM0VKLENBdUVXLENBQVgsQzs7QUFPQSxPQUFBLEdBQVUsdUJBQUEsV0FBQSxFQUFBLFFBQUEsQ0FBVjtBQUVBLGdCQUFBLEtBQUEsR0FBUSwyQkFBQSxPQUFBLENBQVIiLCJzb3VyY2VzQ29udGVudCI6WyJcbmltcG9ydCB7cmUsIHN0cmluZywgbGlzdCBhcyBfbGlzdCwgYmV0d2VlbiwgYWxsLCBhbnksIG1hbnksIG9wdGlvbmFsLFxuICB0YWcsIG1lcmdlLCBqb2luLCBydWxlLCBncmFtbWFyfSBmcm9tIFwicGFuZGEtZ3JhbW1hclwiXG5pbXBvcnQge2lzQXJyYXksIGlzU3RyaW5nfSBmcm9tIFwicGFuZGEtcGFyY2htZW50XCJcblxubG9nID0gKGxhYmVsLCBwKSAtPlxuICBydWxlIHAsIChyZXN1bHQpIC0+XG4gICAgY29uc29sZS5sb2cgW2xhYmVsXTogcmVzdWx0XG4gICAgcmVzdWx0XG5cbndzID0gcmUgL15cXHMrL1xudGV4dCA9IHN0cmluZ1xuc3RyaXAgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT5cbiAgaWYgaXNBcnJheSB2YWx1ZVxuICAgIGl0ZW0gZm9yIGl0ZW0gaW4gdmFsdWUgd2hlbiAhKGlzU3RyaW5nIGl0ZW0pIHx8ICEoL15cXHMrJC8udGVzdCBpdGVtKVxuICBlbHNlIHZhbHVlXG5cbmNvbXBhY3QgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT5cbiAgaXRlbSBmb3IgaXRlbSBpbiB2YWx1ZSB3aGVuIGl0ZW0/XG5cbmZpcnN0ID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+IHZhbHVlWzBdXG5zZWNvbmQgPSAocCkgLT4gcnVsZSBwLCAoe3ZhbHVlfSkgLT4gdmFsdWVbMV1cblxuIyBUT0RPIHdoeSBpc24ndCB0aGlzIGluIHBhcmNobWVudD9cbl9mbGF0dGVuID0gKGF4KSAtPlxuICBieCA9IFtdXG4gIGZvciBhIGluIGF4XG4gICAgaWYgaXNBcnJheSBhIHRoZW4gYngucHVzaCAoX2ZsYXR0ZW4gYSkuLi4gZWxzZSBieC5wdXNoIGFcbiAgYnhcblxuZmxhdHRlbiA9IChwKSAtPiBydWxlIHAsICh7dmFsdWV9KSAtPiBfZmxhdHRlbiB2YWx1ZVxuXG5yZXZlcnNlID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+IHZhbHVlLnJldmVyc2UoKVxuXG5mbGFnID0gKHApIC0+IHJ1bGUgcCwgKHt2YWx1ZX0pIC0+IFt2YWx1ZV06IHRydWVcblxuIyB2ZXJpZnkgY29tbWFuZFxuZGVwZW5kZW5jaWVzID0gdGV4dCBcImRlcGVuZGVuY2llc1wiXG5idWlsZCA9IHRleHQgXCJidWlsZFwiXG5jb25zdHJhaW50cyA9IHRleHQgXCJjb25zdHJhaW50c1wiXG52ZXJpZnkgPSBjb21wYWN0IGFsbCAodGV4dCBcInZlcmlmeVwiKSxcbiAgKG9wdGlvbmFsIGZpcnN0IHN0cmlwIGFsbCB3cyxcbiAgICAodGFnIFwic2NvcGVcIiwgKGFueSBkZXBlbmRlbmNpZXMsIGJ1aWxkLCBjb25zdHJhaW50cykpKVxuXG4jIHVwZGF0ZSBjb21tYW5kXG53aWxkID0gdGV4dCBcIndpbGRcIlxudXBkYXRlID0gY29tcGFjdCBhbGwgKHRleHQgXCJ1cGRhdGVcIiksXG4gIChvcHRpb25hbCBmaXJzdCBzdHJpcCBhbGwgd3MsIGZsYWcgd2lsZClcblxuIyByZWZyZXNoIGNvbW1hbmRcbnJlZnJlc2ggPSBhbGwgdGV4dCBcInJlZnJlc2hcIlxuXG4jIGJ1bXAgY29tbWFuZFxubWFqb3IgPSB0ZXh0IFwibWFqb3JcIlxubWlub3IgPSB0ZXh0IFwibWlub3JcIlxuYnVtcCA9IGNvbXBhY3QgYWxsICh0ZXh0IFwiYnVtcFwiKSxcbiAgKG9wdGlvbmFsIGZpcnN0IHN0cmlwIGFsbCB3cywgKGZsYWcgYW55IG1ham9yLCBtaW5vcikpXG5cbiMgcHVibGlzaCBjb21tYW5kXG5wdWJsaXNoID0gYWxsIHRleHQgXCJwdWJsaXNoXCJcblxuIyBwYWNrYWdlcyBjb21tYW5kXG5saXN0ID0gdGFnIFwic3ViY29tbWFuZFwiLCB0ZXh0IFwibGlzdFwiXG5hZGQgPSB0YWcgXCJzdWJjb21tYW5kXCIsIHRleHQgXCJhZGRcIlxucmVtb3ZlID0gdGFnIFwic3ViY29tbWFuZFwiLCB0ZXh0IFwicmVtb3ZlXCJcbmRpZmYgPSB0YWcgXCJzdWJjb21tYW5kXCIsIHRleHQgXCJkaWZmXCJcbnBhY2thZ2VzID0gc3RyaXAgYWxsICh0ZXh0IFwicGFja2FnZXNcIiksIHdzLCAoYW55IGxpc3QsIGFkZCwgcmVtb3ZlLCBkaWZmKVxuXG4jIGFsbCB0aGUgc3ViY29tbWFuZHNcbnN1YmNvbW1hbmRzID0gKGFueSB2ZXJpZnksIHVwZGF0ZSwgcmVmcmVzaCwgYnVtcCwgcHVibGlzaCwgcGFja2FnZXMpXG5cbiMgcmVoZWFyc2UgY29tbWFuZFxucmVoZWFyc2UgPSBydWxlIChzZWNvbmQgc3RyaXAgYWxsICh0ZXh0IFwicmVoZWFyc2VcIiksIHdzLCBzdWJjb21tYW5kcyksXG4gICh7dmFsdWU6IFtjb21tYW5kLCBvcHRpb25zXX0pIC0+XG4gICAgb3B0aW9ucyA/PSB7fVxuICAgIG9wdGlvbnMucmVoZWFyc2UgPSB0cnVlXG4gICAgW2NvbW1hbmQsIG9wdGlvbnNdXG5cbiMgZ3JhbW1hclxuY29tbWFuZCA9IGFueSBzdWJjb21tYW5kcywgcmVoZWFyc2VcblxucGFyc2UgPSBncmFtbWFyIGNvbW1hbmRcblxuZXhwb3J0IHtwYXJzZX1cbiJdLCJzb3VyY2VSb290IjoiIn0=
//# sourceURL=/Users/dy/repos/dashkite/tempo/src/parse.coffee