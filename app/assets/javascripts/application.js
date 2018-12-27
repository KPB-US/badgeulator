// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require turbolinks
//= require bootstrap-sprockets
//= require jpeg_camera/canvas-to-blob
//= require jpeg_camera/jpeg_camera_no_flash
//= require jpeg_camera_init
//= require jquery.Jcrop
//= require select2
//= require cocoon
//= require_tree .


// init all the static selects
function initSelect2() {
  $('input.select2, select.select2').select2({
    theme: 'bootstrap'
  });
}

// https://stackoverflow.com/a/41915129/1778068
$(document).on("turbolinks:before-cache", function() {
  $('input.select2, select.select2').select2('destroy');
});

$(document).on('turbolinks:load', initSelect2);
