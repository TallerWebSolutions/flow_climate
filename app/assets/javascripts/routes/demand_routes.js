function getDemands(companyId, projectsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/demands/demands_in_projects.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}`
    });
}

function searchDemandsByFlowStatus(companyId, projectsIds, grouping, flowStatus, demandType, demandClassOfService, searchText, startDate, endDate, groupingPeriod) {
    $("#general-loader").show();

    $(".form-control").prop('disabled', true);

    jQuery.ajax({
        url: `/companies/${companyId}/demands/search_demands_by_flow_status.js`,
        type: "GET",
        data: `&projects_ids=${projectsIds}&grouping=${grouping}&flow_status=${flowStatus}&demand_type=${demandType}&demand_class_of_service=${demandClassOfService}&search_text=${searchText}&start_date=${startDate}&end_date=${endDate}&grouping_period=${groupingPeriod}`
    });
}
