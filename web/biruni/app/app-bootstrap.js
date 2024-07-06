angular.element(document).ready(function () {
  angular.bootstrap(document.documentElement, ['app']);

  // Prevent browser from loading a drag-and-dropped file
  $(document).on('dragover drop', function(e){
    return false;
  });
});
