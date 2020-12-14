function getTeamProjectsTab(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/team_projects_tab.js`,
        type: "GET"
    });
}

function getDashboardTab(companyId, teamId, demandsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_tab.js`,
        type: "GET",
        data: `demands_ids=${demandsIds}`
    });
}

function getDashboardPageTwo(companyId, teamId, demandsIds, startDate, endDate) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_page_two.js`,
        type: "GET",
        data: `demands_ids=${demandsIds}&start_date=${startDate}&end_date=${endDate}`
    });
}

function getDashboardPageThree(companyId, teamId, demandsIds, startDate, endDate) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_page_three.js`,
        type: "GET",
        data: `demands_ids=${demandsIds}&start_date=${startDate}&end_date=${endDate}`
    });
}

function getDashboardPageFour(companyId, teamId, demandsIds, startDate, endDate) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_page_four.js`,
        type: "GET",
        data: `demands_ids=${demandsIds}&start_date=${startDate}&end_date=${endDate}`
    });
}

function getDashboardPageFive(companyId, teamId) {
    $("#general-loader").show();
    hideAllTeamTabs();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_page_five.js`,
        type: "GET"
    });
}

function searchTeamDemands(companyId, teamId, demandsIds, flowStatus, demandType, demandClassOfService, searchText, startDate, endDate, searchDemandTags) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_search.js`,
        type: "GET",
        data: `&demands_ids=${demandsIds}&flow_status=${flowStatus}&demand_type=${demandType}&demand_class_of_service=${demandClassOfService}&search_text=${searchText}&start_date=${startDate}&end_date=${endDate}&search_demand_tags=${searchDemandTags}`
    });
}

