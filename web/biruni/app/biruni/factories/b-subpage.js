biruni.factory('bSubpage', function (bBasePage) {

  return function (path, param, xparam) {
    var base = bBasePage(path, param, xparam);

    base.pageType = function() { return "subpage"; }

    let reload = base.reload;
    base.reload = function(__path, __param, __xparam) {
      if (arguments.length > 0 && !_.isEmpty(__path)) {
        base.path = __path;
        base.param = __param || {};
        base.xparam = __xparam || {};
      }
      reload();
    };


    return base;
  };
});