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

$('#operational-charts-period').change(function(event){
    $(".loader").show();
    $('#operational-charts-div').hide();

    event.preventDefault();

    var companyId = $("#company_id").val();
    var teamId = $("#team_id").val();
    var period = $('#operational-charts-period').val();

    buildOperationalCharts(companyId, teamId, period)
});

$('#search_week').on('click', function () {
    var flow_div = $('#flow');
    flow_div.hide();
    $(".loader").show();
    searchDemandsToFlowCharts($('#company_id').val(), $('#team_id').val(), $('#week').val(), $('#year').val());
});
