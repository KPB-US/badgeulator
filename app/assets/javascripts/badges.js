var camera;
var snapshot;   // only one at a time
var jcrop_api;

function startCamera() {
  if ($('#camera').length == 1) {
    console.log('starting camera');
    camera = new JpegCamera("#camera");
  }
}

function handleSnapshotUploadResponse(data) {
  data = JSON.parse(data);
  $('#camerabox').addClass("hidden");
  $('#cropbox img').attr('src', data.url);
  $('#cropbox').removeClass("hidden");

  // default for when no face found
  var face = { x: 1, y: 1, x2: 200 * 0.85, y2: 200 }
  var maxSize = [300 * 0.85, 300];

  z = data.results;
  // console.debug(z);
  if (z && typeof z.faces != "undefined") {
    if (z.faces.length == 0) {
      console.debug("Unable to find face in photo");
      // $('.status').text("Unable to find face in photo");
      // $('.retake2-snapshot').removeClass('hidden');
    } else {
      // found so lets pinpoint
      face = {
        x: z.faces[0].x,
        y: z.faces[0].y,
        x2: z.faces[0].x + z.faces[0].width,
        y2: z.faces[0].y + z.faces[0].height
      };

      // console.debug('origin finding:', face.x, face.y, face.x2, face.y2);

      var w = z.faces[0].width / 6;   // width margin to include
      var h = z.faces[0].height / 3;  // height margin to include
      if (face.x - w > 0) {
        face.x = face.x - w;
      } else {
        face.x = 0;
      }
      if (face.x2 + w < 300) {
        face.x2 = face.x2 + w;
      } else {
        face.x2 = 300;
      }
      if (face.y - h > 0) {
        face.y = face.y - h;
      } else {
        face.y = 0;
      }
      if (face.y2 + h < 400) {
        face.y2 = face.y2 + h;
      } else {
        face.y2 = 400;
      }
      maxSize = [face.x2 - face.x + w * 2, face.y2 - face.y + h * 2];

      // console.debug('  adjusted:', face.x, face.y, face.x2, face.y2, w, h);
    }
  } else {
    console.debug('unable to find face');
    // $('#upload_response').html("Unable to find a face in the photo.");
    // $('.status').empty();
  }

  $('#cropbox img').Jcrop({
    aspectRatio: 0.85,
    setSelect: [face.x, face.y, face.x2, face.y2],
    maxSize: maxSize,
    onChange: updateCrop,
    onSelect: updateCrop
  }, function() {
    jcrop_api = this;
  });
  $('.crop-snapshot').removeClass('hidden');
  $('.retake2-snapshot').removeClass('hidden');
  $('.retake-snapshot').removeClass('hidden');
  $('.step-take').removeClass("step-active");
  $('.step-crop').addClass("step-active");
  $('.status').empty();
}

function takeSnapshot() {
  console.log('taking snapshot');
  snapshot = camera.capture({ mirror: true }).show();

  //$('.retake-snapshot, .use-snapshot').removeClass('hidden');
  $('.take-snapshot').addClass('hidden');
  $('.crop-snapshot').addClass('hidden');
  $('.retake2-snapshot').addClass('hidden');
  $('.status').html("<i class='fa fa-spin fa-spinner'></i> Processing...");

  console.log('uploading snapshot');
  if (snapshot !== null) {
    snapshot.upload({ api_url: $('.use-snapshot').data('url') })
    .done(handleSnapshotUploadResponse)
    .fail(function(status_code, error_message, response) {
      $('#upload_response').html("Upload failed with status " + status_code);
      $('.status').empty();
    });
  }
}

function discardSnapshot() {
  console.log('discarding snapshot');
  if (typeof jcrop_api !== 'undefined' && jcrop_api !== null) {
    jcrop_api.destroy();
    jcrop_api = null;
  }
  if (typeof snapshot !== 'undefined' && snapshot !== null) {
    snapshot.discard();
    snapshot = null;
  }
  $('.status').text("");
  $('#upload_response').html('');
  $('#cropbox').addClass("hidden");
  $('#camerabox').removeClass("hidden");
  $('.take-snapshot').removeClass('hidden');
  $('.retake-snapshot, .use-snapshot').addClass('hidden');
  $('.step-take').addClass("step-active");
  $('.step-crop').removeClass("step-active");
}

function updateCrop(coords) {
  console.log('setting coordinates');
  $('.crop-snapshot').data('coords', coords);
}

function cropSnapshot() {
  console.log('cropping the snapshot');
  $('button.retake2-snapshot').prop('disabled', true);
  $('button.crop-snapshot').html('<i class="fa fa-spin fa-spinner"></i> Working...').prop('disabled', true);
  $.ajax($('.crop-snapshot').data('url'), { data: $('.crop-snapshot').data('coords') })
  .success(function (data, status, jqxhr) {
    console.log('successfully cropped snapshot');

    window.location = data['url'];
  });
}

function handleLookup() {
  console.log("handling lookup");

  $(document)
    .on('ajax:success', '.lookup-form', function (e, data, status, xhr) {
      console.log('lookup success');
      if (typeof data["first_name"] === "undefined" || data["first_name"] === null) {
        $('.lookup-status').text("Employee not found.");
        $('#badge_first_name, #badge_last_name, #badge_department, #badge_title, #badge_employee_id, #badge_dn').val('');
      } else {
        $('.lookup-status').text("");
        $('#badge_first_name').val(data["first_name"]);
        $('#badge_last_name').val(data["last_name"]);
        $('#badge_department').val(data["department"]);
        $('#badge_title').val(data["title"]);
        $('#badge_employee_id').val(data["employee_id"]);
        $('#badge_dn').val(data["dn"]);
      }
    })
    .on('ajax:error', '.lookup-form', function (e, xhr, status, error) {
      console.log('lookup error');
      $('.employee-info').html(error);
    })
    .on('submit', '.lookup-form', function () {
      if ($('#employee_id').val().trim() == '') {
        $('.lookup-status').text("Employee ID is required for lookup.");
        return false;
      } else {
        $('.lookup-status').text("Searching...");
      }
    });

  // wireup generate button
  $(document).on('click', 'a.generate-badge', function () {
    $(this).html('<i class="fa fa-spin fa-spinner"></i> Generating...').addClass('disabled');
  });

  // handle publish results
  $(document)
    .on('ajax:success', '.ujs-publish', function (e, data, status, xhr) {
      if (data['status'] === 'N') {
        $('td#publish_' + data['id']).text('failed');
        console.error('could not publish photo to ad', data['message']);
      } else {
        $('td#publish_' + data['id']).text('Y');
        console.debug('published photo to ad', data);
      }
    })
    .on('ajax:error', '.ujs-publish', function (e, xhr, status, error) {
      console.error('could not publish photo to ad', data['message']);
    })

  // wireup file upload form for upload images instead of using camera
  $(document)
    .on('ajax:success', '.upload-pic', function (e, data, status, xhr) {
      console.log('upload  success');
      //console.debug(data);
      //handleSnapshotUploadResponse(data);
    })
    .on('ajax:error', '.upload-pic', function (e, xhr, status, error) {
      console.log('upload error');
      $('#upload_response').html("Unable to upload the photo. Must be jpg or jpeg.");
      $('.status').empty();
    })
    .on('submit', '.upload-pic', function () {
      console.debug('upload submitted');
    });
}

$(document).ready(handleLookup);
$(document).on('page:load', handleLookup);
