var _initGuesswho = false;

function initGuesswho() {
  var failed = 0;
  var correct = 0;

  if (_initGuesswho) {
    return;
  }

  console.log('guesswho initialized');

  function dragstart_handler(ev) {
    // Add the target element's id to the data transfer object
    var id = $(ev.target).data('id');
    ev.originalEvent.dataTransfer.setData("text", '' + id);
    console.log('dragging', id);
  }
  
  function drop_handler(ev) {
    ev.originalEvent.preventDefault();
    // Get the id of the target and add the moved element to the target's DOM
    var sourceId = ev.originalEvent.dataTransfer.getData("text");
    var destinationId = $(ev.originalEvent.target).data('id');
    if (!destinationId) {
      // console.log('looking up');
      destinationId = $(ev.originalEvent.target).closest('.person').data('id');
    }
    console.log('dropped', sourceId, 'on', destinationId);
    var person = $('.person[data-id=' + destinationId + ']');
    
    // don't handle drops if already guessed correctly
    if (person.hasClass('correct')) {
      return;
    }

    if (sourceId == destinationId) {
      var nameTag = $('.name-tag[data-id=' + sourceId + ']');
      $('.person[data-id=' + destinationId + '] .caption').html($(nameTag).find('.caption').html());
      nameTag.addClass('used').removeAttr('draggable');
      person.addClass('correct');
      correct++;
    } else {
      person.addClass('missed');
      setTimeout(function(){
        person.removeClass('missed');
      }, 1000);
      failed++;
    }

    $('.scoreboard').text("" + Math.round(correct / (correct + failed) * 100.0) + "%, Guesses " + (correct + failed));
    if (correct >= failed) {
      $('.scoreboard').addClass('good');
    } else {
      $('.scoreboard').removeClass('good');
    }
  }

  function dragover_handler(ev) {
    ev.originalEvent.preventDefault();
  }

  $('div.guesswho').on('dragstart', '.name-tag', dragstart_handler);
  $('div.guesswho').on('dragover', '.person', dragover_handler);
  $('div.guesswho').on('drop', '.person', drop_handler);

//  _initGuesswho = true;
}

$(document).on('turbolinks:load', initGuesswho);
