biruni.factory('bGridScroll', function() {
  return function(name) {
    var g = {
      name: name,
      id: '',
      scroll: ''
    };

    function id(val) {
      if (arguments.length) {
        g.id = val;
      }
      return g.id;
    }

    function scroll(val) {
      if (arguments.length) {
        g.scroll = val;
      }
      return g.scroll;
    }

    return { id, scroll };
  };
});