$(".loader").hide();

const hoursGauge = $('#hours-gauge');
buildGaugeChart(hoursGauge);

accordionBehaviour();

$('#status-report-period').on('change', function(event){
    $(".loader").show();
    $('#project-status-report').hide();

    event.preventDefault();

    const companyId = $("#company_id").val();
    const teamId = $("#team_id").val();
    const period = $('#status-report-period').val();

    buildStatusReportCharts(companyId, teamId, period)
});

$('#operational-charts-period').change(function(event){
    $(".loader").show();
    $('#operational-charts-div').hide();

    event.preventDefault();

    const companyId = $("#company_id").val();
    const period = $('#operational-charts-period').val();
    const projects_ids = $("#projects_ids").val();

    buildOperationalCharts(companyId, projects_ids, period)
});

$('#search_week').on('click', function () {
    const flow_div = $('#flow');
    flow_div.hide();
    $(".loader").show();
    searchDemandsToFlowCharts($('#company_id').val(), $('#team_id').val(), $('#week').val(), $('#year').val());
});
