biruni.directive('bSubpage', function(bSubpage, bFrame, $parse) {

  function controller($scope, $attrs) {
    let parent = $scope.bPage;
    $scope.bParentPage  = parent;
    $scope.bPage = null;

    assert(parent.pageType() == "parent", "subpage cannot create inner subpage");

    parent.addSubpage($attrs.name, bSubpage());
  }

  function link(scope, elem, attr) {
    elem.hide();
    var parent = scope.bParentPage;
    assert(parent.pageType() == "parent", "subpage cannot create inner subpage");
    var formGetter = $parse(attr.form);
    var paramGetter = $parse(attr.param);
    var xparamGetter = $parse(attr.xparam);

    var subpage = parent.subpage(attr.name);

    //@overide
    subpage.openFunc        = bFrame.openDialog;
    subpage.openDialogFunc  = bFrame.openDialog;
    subpage.openReplace     = bFrame.openReplace;

    subpage.runFunc = function(...args) {
      subpage.reload(...args);
      subpage.qContentLink.resolve({
        scope: scope,
        elem: elem
      });
    }

    /**
     * Subpage cannot be dialog.
     * Even if subpage parent is dialog it cannot return data
     */
    subpage.setDialog(false);

    subpage.setFirst(true);

    scope.bParentPage = parent;
    parent.qLoaded.promise.then(function() {
      let form = formGetter(scope);
      if (form) {
        let param = paramGetter(scope);
        let xparam = xparamGetter(scope);

        subpage.run(form, param, xparam);
      }
    });

  }

  return {
    restrict: 'E',
    controller: controller,
    link: link,
    scope: true
  }
});