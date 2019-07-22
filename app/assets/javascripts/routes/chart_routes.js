function buildOperationalCharts(companyId, projectsIds, period, targetName, startDate, endDate, teamId) {
    $("#general-loader").show();
    $("#operational-charts-div").hide();
    $("#status-report-charts-current-div").hide();
    $("#status-report-charts-projection-div").hide();

    jQuery.ajax({
        url: `/companies/${companyId}/build_operational_charts.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}&period=${period}&target_name=${targetName}&start_date=${startDate}&end_date=${endDate}&period=${period}&team_id=${teamId}`
    });
}

function buildStrategicCharts(companyId, projectsIds, targetName) {
    jQuery.ajax({
        url: `/companies/${companyId}/build_strategic_charts.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}&target_name=${targetName}`
    });
}

function statisticsChartsRoute(companyId, projectsIds, period, targetName, startDate, endDate, statsLeadtimeConfidence, projectStatus) {
    $("#general-loader").show();
    $("#stats-charts-body").hide();

    jQuery.ajax({
        url: `/companies/${companyId}/statistics_charts.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}&period=${period}&target_name=${targetName}&start_date=${startDate}&end_date=${endDate}&project_status=${projectStatus}&leadtime_confidence=${statsLeadtimeConfidence}`
    });
}
