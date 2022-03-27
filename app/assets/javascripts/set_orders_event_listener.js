set_orders_event_listener = function() {
  return $('#orders').find('form').each(function(i, el) {
    var $btn, $form;
    $form = $(el);
    $btn = $form.find('button');
    return $btn.on('click', function(e) {
      e.preventDefault();
      return $.ajax({
        method: 'patch',
        url: $form.attr('action'),
        beforeSend: function(xhr) {
          return xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        data: {
          'order': {
            acknowledged: true
          }
        },
        dataType: 'json',
        error: function() {
          return console.log('error: patch order ajax request');
        },
        success: function(response) {
          return $form.closest('tr').remove();
        }
      });
    });
  });
};
