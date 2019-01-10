function initGuesswho() {
  var failed = 0;
  var correct = 0;

  console.log('guesswho initialized');
  // $(document).on('change', 'select.submit-on-change', function () {
  //   this.form.submit();
  // });

  function dragstart_handler(ev) {
    // console.log("dragStart", ev);
    // Add the target element's id to the data transfer object
    ev.originalEvent.dataTransfer.setData("text/plain", $(ev.currentTarget).data('id'));
    ev.originalEvent.dropEffect = "move";
  }
  
  function drop_handler(ev) {
    ev.originalEvent.preventDefault();
    // Get the id of the target and add the moved element to the target's DOM
    var data = ev.originalEvent.dataTransfer.getData("text/plain");
    // console.log('dropped', data);
    // ev.target.appendChild(document.getElementById(data));

    var dropped_on = $(ev.originalEvent.target).data('id');
    if (!dropped_on) {
      // console.log('looking up');
      dropped_on = $(ev.originalEvent.target).closest('.person').data('id');
    }
    // console.log('dropped on', dropped_on, ev.originalEvent);
    if (data == dropped_on) {
      var nameTag = $('.name-tag[data-id=' + data + ']');
      $('.person[data-id=' + data + '] .caption').html($(nameTag).find('.caption').html());
      nameTag.addClass('used').removeAttr('draggable');
      correct++;
    } else {
      console.log('boo');
      failed++;
    }

    $('.scoreboard').text("Correct " + correct + ", Missed " + failed);

  }

  function dragover_handler(ev) {
    ev.originalEvent.preventDefault();
    // Set the dropEffect to move
    ev.originalEvent.dataTransfer.dropEffect = "move"
  }

  $('div.guesswho').on('dragstart', '.name-tag', dragstart_handler);
  $('div.guesswho').on('dragover', '.person', dragover_handler);
  $('div.guesswho').on('drop', '.person', drop_handler);
}

$(document).on('turbolinks:load', initGuesswho);
