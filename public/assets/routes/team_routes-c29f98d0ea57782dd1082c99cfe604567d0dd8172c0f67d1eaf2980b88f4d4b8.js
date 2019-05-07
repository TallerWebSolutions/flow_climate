function buildReplenishingMeeting(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/replenishing_input.js`,
        type: "GET"
    });
}

function getTeamStatistics(companyId, teamId, startDate, endDate, period) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/statistics_tab.js`,
        type: "GET",
        data: `start_date=${startDate}&end_date=${endDate}&period=${period}`
    });
}
;
