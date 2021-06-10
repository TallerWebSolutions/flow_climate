function searchDemands(companyId, demandsIds, demandState, demandType, demandClassOfService, searchText, startDate, endDate, searchDemandTags) {
    $("#general-loader").show();

    $(".form-control").prop('disabled', true);

    jQuery.ajax({
        url: `/companies/${companyId}/demands/search_demands.js`,
        type: "POST",
        data: `&demands_ids=${demandsIds}&demand_state=${demandState}&demand_type=${demandType}&demand_class_of_service=${demandClassOfService}&search_text=${searchText}&start_date=${startDate}&end_date=${endDate}&search_demand_tags=${searchDemandTags}`
    });
}

function destroyDemand(companyId, demandId, confirmationMessage, demandsIds) {
    if (window.confirm(confirmationMessage)) {
        jQuery.ajax({
            url: `/companies/${companyId}/demands/${demandId}.js`,
            type: "DELETE",
            data: `&demands_ids=${demandsIds.join(",")}`
        });
    }
}

function editDemand(companyId, projectId, demandId) {
    jQuery.ajax({
        url: `/companies/${companyId}/projects/${projectId}/demands/${demandId}/edit.js`,
        type: "GET"
    });
};
