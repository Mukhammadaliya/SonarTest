biruni.factory('bPage', function (bBasePage) {
  return function (hash, path, param, xparam) {
    var base = bBasePage(path, param, xparam);

    base.pageType = function() { return "parent"; }

    base.hash = hash;
    base.subpages = {};

    function subpage(name) {
      assert(_.isString(name) && name, "Invalid subpage name");

      assert(base.subpages[name], `Subpage is not defined, name: ${name}`);

      return base.subpages[name];
    }

    function addSubpage(name, subpage) {
      assert(subpage, "Subpage is undefined");

      base.subpages[name] = subpage;
    }

    // add new functions

    base.subpage = subpage;
    base.addSubpage = addSubpage;

    // add api

    base.addApi("subpage", subpage);

    // @overide functions

    let reload = base.reload;
    base.reload = function() {
      $('html').animate({ scrollTop: 0 }, 200);
      base.subpages = {};
      reload();
    };

    let setTitle = base.setTitle;
    base.setTitle = function(title) {
      document.title = title;
      setTitle(title);
    }

    base.reload();

    return base;
  };
});