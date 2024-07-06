biruni.factory('bContentMaker', function($q, $compile, $rootScope, $timeout) {
  function Maker() {
    var scope = $rootScope.$new(true);

    function render(text, data) {
      let deferred = $q.defer();
      let elem = angular.element(`<div>${text}</div>`);
      
      _.each(data, (v, k) => scope[k] = v);
      $compile(elem)(scope);
      $timeout(() => deferred.resolve(elem[0].outerHTML));

      return deferred.promise;
    }
    
    return {
      render: render
    };
  }

  return function() {
    return new Maker();
  }
});