// WARNING!
// LINES BELOW ARE IGNORED IN THE PRODUCTION ENV IF IT IS TAGGED WITH THE COMMENT: /*DEV*/
biruni.run(function($templateCache) {
  [
    'b-grid-filter-panel',
    'b-input',
    'b-grid-controller',
    'b-pg-controller',
    /*DEV*/ 'b-tdev',
    'b-dropzone',
    'b-cropper',
    'b-tree-select',
    'b-content-maker',
    'b-dynamic-field'
  ].forEach(function(template) {
    $.ajax({
      method: "GET",
      url: `biruni/app/biruni/directives/${template}/${template}.html`,
      success: function(result) {
        $templateCache.put(`${template}.html`, result);
      },
      async: false
    });
  });
});
