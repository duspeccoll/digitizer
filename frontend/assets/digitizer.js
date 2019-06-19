function Digitizer($digitizer_form) {
  this.$digitizer_form = $digitizer_form;
  this.setup_form();
}

Digitizer.prototype.setup_form = function() {
  var self = this;
  $(document).trigger("loadedrecordsubforms.aspace", this.$digitizer_form);
};

$(document).ready(function() {
  var digitizer = new Digitizer($("#digitizer_form"));
});
