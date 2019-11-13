function buildReplenishingMeeting(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/replenishing_input.js`,
        type: "GET"
    });
}

function getProjectsTab(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/projects_tab.js`,
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
