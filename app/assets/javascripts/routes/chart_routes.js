function buildOperationalCharts(company_id, projects_ids, period) {
    $(".loader").show();

    jQuery.ajax({
        url: "/companies/" + company_id + "/build_operational_charts" + ".js",
        type: "GET",
        data: 'projects_ids=' + projects_ids + '&period=' + period
    });
}

function buildStrategicCharts(company_id, projects_ids) {
    jQuery.ajax({
        url: "/companies/" + company_id + "/build_strategic_charts" + ".js",
        type: "GET",
        data: 'projects_ids=' + projects_ids
    });
}

function buildStatusReportCharts(company_id, projects_ids, period) {
    jQuery.ajax({
        url: "/companies/" + company_id + "/build_status_report_charts" + ".js",
        type: "GET",
        data: 'projects_ids=' + projects_ids + '&period=' + period
    });
}
