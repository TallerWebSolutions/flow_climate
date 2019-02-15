function buildReplenishingMeeting(companyId, teamId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/replenishing_input.js`,
        type: "GET"
    });
}
;
