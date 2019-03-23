function buildOperationalCharts(company_id, projects_ids, period, target_name, startDate, endDate) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${company_id}/build_operational_charts.js`,
        type: "GET",
        data: `projects_ids=${projects_ids}&period=${period}&target_name=${target_name}&start_date=${startDate}&end_date=${endDate}&period=${period}`
    });
}

function buildStrategicCharts(company_id, projects_ids, target_name) {
    jQuery.ajax({
        url: `/companies/${company_id}/build_strategic_charts.js`,
        type: "GET",
        data: `projects_ids=${projects_ids}&target_name=${target_name}`
    });
}

function buildStatusReportCharts(company_id, projects_ids, period, target_name, startDate, endDate) {
    jQuery.ajax({
        url: `/companies/${company_id}/build_status_report_charts.js`,
        type: "GET",
        data: `projects_ids=${projects_ids}&period=${period}&target_name=${target_name}&start_date=${startDate}&end_date=${endDate}&period=${period}`
    });
}
