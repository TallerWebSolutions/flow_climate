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

function getDemandsTab(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/demands_tab.js`,
        type: "GET"
    });
}

function getDashboardTab(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_tab.js`,
        type: "GET"
    });
}
