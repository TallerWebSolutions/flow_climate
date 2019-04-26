function getDemands(companyId, projectsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/demands/demands_in_projects.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}`
    });
}

function searchDemands(companyId, projectsIds, grouping, flowStatus, demandType, demandClassOfService, searchText, startDate, endDate, groupingPeriod) {
    $("#general-loader").show();

    $(".form-control").prop('disabled', true);

    jQuery.ajax({
        url: `/companies/${companyId}/demands/search_demands.js`,
        type: "GET",
        data: `&projects_ids=${projectsIds}&grouping=${grouping}&flow_status=${flowStatus}&demand_type=${demandType}&demand_class_of_service=${demandClassOfService}&search_text=${searchText}&start_date=${startDate}&end_date=${endDate}&grouping_period=${groupingPeriod}`
    });
}

function destroyDemand(companyId, demandId, confirmationMessage, demandsIds) {
    if (window.confirm(confirmationMessage)) {
        var grouping = $('#demands-table-grouping-period').val();
        jQuery.ajax({
            url: `/companies/${companyId}/demands/${demandId}.js`,
            type: "DELETE",
            data: `&demands_ids=${demandsIds.join(",")}&grouping=${grouping}`
        });
    }
}

function editDemand(companyId, projectId, demandId, demandsIds) {
    jQuery.ajax({
        url: `/companies/${companyId}/projects/${projectId}/demands/${demandId}/edit.js`,
        type: "GET",
        data: `&demands_ids=${demandsIds}`
    });
}
