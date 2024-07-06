biruni.directive('bPage', function (bFrame) {
  function link(scope, elem) {
    elem.hide();
    var page = bFrame.findPage(scope.bPageID);
    var reload = page.reload;

    // @overide
    page.openFunc = bFrame.open;
    page.openDialogFunc = bFrame.openDialog;
    page.openReplaceFunc = bFrame.openReplace;
    page.openClearFunc = bFrame.openClear;
    page.closeFunc = bFrame.close;
    page.setFavorite = bFrame.setFavorite;

    page.runFunc = function() {
      reload();
      bFrame.refreshIds();
    }

    page.setDialog(bFrame.pages.length > 1 && bFrame.pages[bFrame.pages.length - 2].saved);
    page.setFirst(bFrame.pages.length <= 1);

    page.qContentLink.resolve({
      scope : scope,
      elem : elem
    });
    scope.a = null;
  }

  return {
    restrict : 'E',
    link : link,
    scope : true
  }
});
