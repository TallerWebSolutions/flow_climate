function buildOperationalCharts(company_id, team_id) {
    $(".loader").show();
    jQuery.ajax({
        url: "/companies/" + company_id + "/teams/" + team_id + "/build_operational_charts" + ".js",
        type: "GET"
    });
}

function searchDemandsToFlowCharts(company_id, team_id, week, year) {
    jQuery.ajax({
        url: "/companies/" + company_id + "/teams/" + team_id + "/search_demands_to_flow_charts" + ".js",
        type: "GET",
        data: 'year=' + year +'&week=' + week
    });
}
