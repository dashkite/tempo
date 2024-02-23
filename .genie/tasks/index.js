"use strict";
Object.defineProperty(exports, "__esModule", {
    value: true
});
const _promises = /*#__PURE__*/ _interop_require_default(require("node:fs/promises"));
const _genie = /*#__PURE__*/ _interop_require_wildcard(require("@dashkite/genie"));
function _interop_require_default(obj) {
    return obj && obj.__esModule ? obj : {
        default: obj
    };
}
function _getRequireWildcardCache(nodeInterop) {
    if (typeof WeakMap !== "function") return null;
    var cacheBabelInterop = new WeakMap();
    var cacheNodeInterop = new WeakMap();
    return (_getRequireWildcardCache = function(nodeInterop) {
        return nodeInterop ? cacheNodeInterop : cacheBabelInterop;
    })(nodeInterop);
}
function _interop_require_wildcard(obj, nodeInterop) {
    if (!nodeInterop && obj && obj.__esModule) {
        return obj;
    }
    if (obj === null || typeof obj !== "object" && typeof obj !== "function") {
        return {
            default: obj
        };
    }
    var cache = _getRequireWildcardCache(nodeInterop);
    if (cache && cache.has(obj)) {
        return cache.get(obj);
    }
    var newObj = {
        __proto__: null
    };
    var hasPropertyDescriptor = Object.defineProperty && Object.getOwnPropertyDescriptor;
    for(var key in obj){
        if (key !== "default" && Object.prototype.hasOwnProperty.call(obj, key)) {
            var desc = hasPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : null;
            if (desc && (desc.get || desc.set)) {
                Object.defineProperty(newObj, key, desc);
            } else {
                newObj[key] = obj[key];
            }
        }
    }
    newObj.default = obj;
    if (cache) {
        cache.set(obj, newObj);
    }
    return newObj;
}
// TODO incorporate into preset
_genie.define("bin", async function() {
    await _promises.default.mkdir("build/node/src/bin", {
        recursive: true
    });
    return _promises.default.copyFile("src/bin/tempo", "build/node/src/bin/tempo");
});
_genie.after("build", "bin"); //# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiIiwic291cmNlUm9vdCI6IiIsInNvdXJjZXMiOlsiL3Rhc2tzL2luZGV4LmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQSxPQUFPLEVBQVAsTUFBQTs7QUFDQSxPQUFPLENBQUEsU0FBUCxNQUFBLGtCQURBOzs7QUFJQSxLQUFLLENBQUMsTUFBTixDQUFhLEtBQWIsRUFBb0IsTUFBQSxRQUFBLENBQUEsQ0FBQTtFQUNsQixNQUFNLEVBQUUsQ0FBQyxLQUFILENBQVMsb0JBQVQsRUFBK0I7SUFBQSxTQUFBLEVBQVc7RUFBWCxDQUEvQjtTQUNOLEVBQUUsQ0FBQyxRQUFILENBQVksZUFBWixFQUE2QiwwQkFBN0I7QUFGa0IsQ0FBcEI7O0FBSUEsS0FBSyxDQUFDLEtBQU4sQ0FBWSxPQUFaLEVBQXFCLEtBQXJCIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IEZTIGZyb20gXCJub2RlOmZzL3Byb21pc2VzXCJcbmltcG9ydCAqIGFzIEdlbmllIGZyb20gXCJAZGFzaGtpdGUvZ2VuaWVcIlxuXG4jIFRPRE8gaW5jb3Jwb3JhdGUgaW50byBwcmVzZXRcbkdlbmllLmRlZmluZSBcImJpblwiLCAtPlxuICBhd2FpdCBGUy5ta2RpciBcImJ1aWxkL25vZGUvc3JjL2JpblwiLCByZWN1cnNpdmU6IHRydWVcbiAgRlMuY29weUZpbGUgXCJzcmMvYmluL3RlbXBvXCIsIFwiYnVpbGQvbm9kZS9zcmMvYmluL3RlbXBvXCJcblxuR2VuaWUuYWZ0ZXIgXCJidWlsZFwiLCBcImJpblwiIl19
 //# sourceURL=/tasks/index.coffee

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi90YXNrcy9pbmRleC5jb2ZmZWUiXSwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IEZTIGZyb20gXCJub2RlOmZzL3Byb21pc2VzXCJcbmltcG9ydCAqIGFzIEdlbmllIGZyb20gXCJAZGFzaGtpdGUvZ2VuaWVcIlxuXG4jIFRPRE8gaW5jb3Jwb3JhdGUgaW50byBwcmVzZXRcbkdlbmllLmRlZmluZSBcImJpblwiLCAtPlxuICBhd2FpdCBGUy5ta2RpciBcImJ1aWxkL25vZGUvc3JjL2JpblwiLCByZWN1cnNpdmU6IHRydWVcbiAgRlMuY29weUZpbGUgXCJzcmMvYmluL3RlbXBvXCIsIFwiYnVpbGQvbm9kZS9zcmMvYmluL3RlbXBvXCJcblxuR2VuaWUuYWZ0ZXIgXCJidWlsZFwiLCBcImJpblwiIl0sIm5hbWVzIjpbIkdlbmllIiwiZGVmaW5lIiwiRlMiLCJta2RpciIsInJlY3Vyc2l2ZSIsImNvcHlGaWxlIiwiYWZ0ZXIiXSwibWFwcGluZ3MiOiI7Ozs7aUVBQUE7K0RBQ0E7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7OztBQUdBQSxPQUFNQyxNQUFOLENBQWEsT0FBTztJQUNsQixNQUFNQyxpQkFBRSxDQUFDQyxLQUFILENBQVMsc0JBQXNCO1FBQUFDLFdBQVc7SUFBWDtXQUNyQ0YsaUJBQUUsQ0FBQ0csUUFBSCxDQUFZLGlCQUFpQjtBQUZYO0FBSXBCTCxPQUFNTSxLQUFOLENBQVksU0FBUyJ9