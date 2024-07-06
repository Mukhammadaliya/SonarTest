app.factory('AppFeedback', function(bRoutes, $http) {
  var $modal = $('#sendFeedback');

  var feedback = {
    open,
    send,
    changeRate
  }

  function setInitialData() {
    feedback.sended = false;
    feedback.rate_invalid = false;
    feedback.rate = '';
    feedback.type = 'S';
    feedback.note = '';
    feedback.anonymous = 'N';
  }

  function open() {
    setInitialData();
    var form = $modal.scope().form;

    form.$setPristine();
    form.$setUntouched();

    $modal.modal('show');
  }

  function changeRate(rate) {
    feedback.rate = rate;
    feedback.rate_invalid = false;
  }

  function formValid(form) {
    form.$setSubmitted();
    return form.$valid;
  }

  function send() {
    if (formValid($modal.scope().form) && feedback.rate != '') {
      var data = _.pick(feedback, 'rate', 'type', 'anonymous', 'note');
      $http.post(bRoutes.SEND_FEEDBACK, data).then(() => {
        feedback.sended = true;
      });
    } else {
      feedback.rate_invalid = true;
    }
  }

  return feedback;
});