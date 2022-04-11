$("#general-loader").hide();

$("#project-demands-dashboard").show();
$("#project-tasks-dashboard").hide();

$('#demands_charts_tab').addClass('active');
$('#tasks_charts_tab').removeClass('active');

$('#tasks_charts_tab').click(function() {
  var isTasksTabActive = $('#demands_charts_tab').hasClass('active');

  if(isTasksTabActive) {
    $("#project-demands-dashboard").hide();
    $('#general-loader').show();
  }
});

$('#demands_charts_tab').click(function() {
  var isDemandsTabActive = $('#tasks_charts_tab').hasClass('active');

  if(isDemandsTabActive) {
    $("#project-tasks-dashboard").hide();
    $('#general-loader').show();
  }
});
