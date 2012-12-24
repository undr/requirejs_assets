(function() {
  var variable = "value";
  var object = {
    method: function(a, b) {
      if(a) {
        return function() {
          return b;
        };
      } else {
        return b;
      }
    },
    property: variable
};
  var module = (function(object) {
    object.submodule = {
      method: function() {

      }
};
    return object;
  }).call(object);
  var shim_module = module;
  define('shim_module', ["dep1", "dep2"], shim_module)
}).call(this);

