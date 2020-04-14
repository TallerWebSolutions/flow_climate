function buildReplenishingMeeting(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/replenishing_input.js`,
        type: "GET"
    });
}

function getTeamProjectsTab(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/team_projects_tab.js`,
        type: "GET"
    });
}

function getDemandsTab(companyId, teamId, demandsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/demands_tab.js`,
        type: "GET",
        data: `demands_ids=${demandsIds}`
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

function searchDashboard(companyId, teamId, projectStatus, demandStatus, demandsType, demandsClassOfService, startDate, endDate) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_search.js`,
        type: "GET",
        data: `&project_status=${projectStatus}&demand_status=${demandStatus}&demand_type=${demandsType}&demand_class_of_service=${demandsClassOfService}&start_date=${startDate}&end_date=${endDate}`
    });
}
