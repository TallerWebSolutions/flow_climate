$("#projects-lead-time-tab").addClass('active');
$("#projects-lead-time-container").show();

$(".leadtime-evolution").each(function(index, element) {
    buildLineChart($("#" + element.id));
});
