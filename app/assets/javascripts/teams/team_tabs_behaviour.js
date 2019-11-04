$("#team-demands-tab").on("click", function() {
    $("#team-dashboard-info").hide();

    let companyId = $("#company_id").val();
    let teamId = $("#team_id").val();

    $("#team-dashboard-tab").removeClass('active');
    $("#team-demands-tab").addClass('active');

    getDemandsTab(companyId, teamId);
});

$("#team-dashboard-tab").on("click", function() {
    $("#team-demands-info").hide();

    let companyId = $("#company_id").val();
    let teamId = $("#team_id").val();

    $("#team-demands-tab").removeClass('active');
    $("#team-dashboard-tab").addClass('active');

    getDashboardTab(companyId, teamId);
});
