biruni.directive('bOffcanvas', function ($timeout) {

  function link(scope, elem) {
    var toggler = $('<button type="button">').addClass('offcanvas-toggle-btn').appendTo(elem);
    toggler.append($('<i class="fa fa-arrow-right">'));
    toggler.click(function() {
      var parent = $(this).parent();
      parent.find('.card-body').fadeOut(0);
      parent.toggleClass('active');
      $(this).find('i').toggleClass('fa-arrow-right').toggleClass('fa-arrow-left');

      setTimeout(function() {
        parent.find('.card-body').fadeIn(300);
      }, 300);
    });

    $('#kt_wrapper').children('.content,#kt_footer').addClass(['pl-27', 'pl-lg-0']);

    scope.$on('$destroy', function() {
      $('#kt_wrapper').children('.content,#kt_footer').removeClass(['pl-27', 'pl-lg-0']);
    });
  }

  return {
    restrict : 'C',
    link : link
  }
});