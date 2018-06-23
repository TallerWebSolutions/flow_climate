$(".loader").hide();

var hoursGauge = $('#hours-gauge');
buildGaugeChart(hoursGauge);

accordionBehaviour();

$('#status-report-period').on('change', function(event){
    $(".loader").show();
    $('#project-status-report').hide();

    event.preventDefault();

    var companyId = $("#company_id").val();
    var teamId = $("#team_id").val();
    var period = $('#status-report-period').val();

    buildStatusReportCharts(companyId, teamId, period)
});
