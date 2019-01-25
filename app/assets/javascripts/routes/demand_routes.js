function getDemands(companyId, projectsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/demands/demands_in_projects.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}`
    });
}

function searchDemandsByFlowStatus(companyId, projectsIds, flatDemands, groupedByMonth, groupedByCustomer, notStarted, committed, delivered, featureType, bugType, performanceImprovement, choreType, uiType, wireframeType, standardClass, expediteClass, fixedDateClass, intangibleClass, searchText, period) {
    $("#general-loader").show();

    $(".form-control").prop('disabled', true);
    $(".filter-checks").prop('disabled', true);

    jQuery.ajax({
        url: `/companies/${companyId}/demands/search_demands_by_flow_status.js`,
        type: "GET",
        data: `&flat_demands=${flatDemands}&projects_ids=${projectsIds}&grouped_by_month=${groupedByMonth}&grouped_by_customer=${groupedByCustomer}&not_started=${notStarted}&wip=${committed}&delivered=${delivered}&feature_type=${featureType}&bug_type=${bugType}&performance_improvement_type=${performanceImprovement}&ui_type=${uiType}&wireframe_type=${wireframeType}&chore_type=${choreType}&standard_class=${standardClass}&expedite_class=${expediteClass}&fixed_date_class=${fixedDateClass}&intangible_class=${intangibleClass}&search_text=${searchText}&period=${period}`
    });
}
