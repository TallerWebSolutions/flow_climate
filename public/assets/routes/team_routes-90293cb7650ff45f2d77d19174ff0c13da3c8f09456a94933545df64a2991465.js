function searchDemandsToFlowCharts(company_id, team_id, week, year) {
    jQuery.ajax({
        url: "/companies/" + company_id + "/teams/" + team_id + "/search_demands_to_flow_charts" + ".js",
        type: "GET",
        data: 'year=' + year +'&week=' + week
    });
}

function searchDemandsByFlowStatus(companyId, teamId, flatDemands, groupedByMonth, groupedByCustomer, notStarted, committed, delivered) {
    jQuery.ajax({
        url: "/companies/" + company_id + '/teams/' + team_id + "/search_demands_by_flow_status" + ".js",
        type: "GET",
        data: '&flat_demands=' + flatDemands + '&grouped_by_month=' + groupedByMonth + '&grouped_by_customer=' + groupedByCustomer + '&not_started=' + notStarted + '&wip=' + committed + '&delivered=' + delivered
    });
}
;
