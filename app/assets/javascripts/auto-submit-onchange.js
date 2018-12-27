function hookSubmitOnChange() {
  $(document).on('change', 'select.submit-on-change', function () {
    this.form.submit();
  });
}

$(document).on('turbolinks:load', hookSubmitOnChange);
