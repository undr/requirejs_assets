define('module_one', ['dependency_one', 'dependency_two'], function() {

});
define('module_two', ['module_one'], function() {
  var method = function(x, y) {
    return [x, y];
  };
  return method('application', ['module1', 'module2']);
});
define('module_three', ['dependency_two', 'dependency_three'], function() {

});

