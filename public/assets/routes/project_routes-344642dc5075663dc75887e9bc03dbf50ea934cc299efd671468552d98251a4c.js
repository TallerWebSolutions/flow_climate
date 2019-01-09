function searchDemandsByFlowStatus(companyId, demandsIds, flatDemands, groupedByMonth, groupedByCustomer, notStarted, committed, delivered) {
    jQuery.ajax({
        url: "/companies/" + companyId + "/demands/search_demands_by_flow_status" + ".js",
        type: "GET",
        data: '&flat_demands=' + flatDemands + '&demands_ids=' + demandsIds + '&grouped_by_month=' + groupedByMonth + '&grouped_by_customer=' + groupedByCustomer + '&not_started=' + notStarted + '&wip=' + committed + '&delivered=' + delivered
    });
}
;
