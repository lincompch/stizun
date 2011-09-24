$(document).ready(function() {
  var batch_values = $.cookie("batch");
  if(batch_values !== null && batch_values !== "") {
    $("#batch").html("Editing multiple products");
    var array = batch_values.split(':');
    $.each(array, function(i, val){
      $("#product_id_" + val).prop("checked", true);
    });
  }

  $('input[type="checkbox"].batch').change(function() {
    var values = $.cookie("batch");
    if(values !== null && values !== "") {
      var array = values.split(':');
    }
    else{
      var array = new Array();
    }

    var value = $(this).val();

    if(values !== null && ($.inArray(value, array) > -1) ){
      array = $.grep(array, function(val) { return val != value; });
    }
    else{
      array.push(value);
    }
    if(array.length != 0) {
      $.cookie("batch", array.join(":"), { path: "/" });
      $("#batch").html("Editing multiple products");
    }else{
      $.cookie("batch", null, { path: "/" });
      $("#batch").html("No batch products");
    }
  });
});

