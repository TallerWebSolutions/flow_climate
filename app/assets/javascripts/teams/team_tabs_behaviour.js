function bindDashboardSelectors() {
    $("#team-demands-tab").on("click", function() {
        $("#team-dashboard-info").hide();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();

        $("#team-dashboard-tab").removeClass('active');
        $("#team-demands-tab").addClass('active');

        $('#page-buttons').hide();

        getDemandsTab(companyId, teamId);
    });

    $("#team-dashboard-tab, #team-dashboard-page-one").on("click", function() {
        $("#team-dashboard-container-page-two").hide();
        $("#team-demands-info").hide();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();

        $("#team-demands-tab").removeClass('active');
        $("#team-dashboard-page-two").removeClass('active');
        $("#team-dashboard-tab").addClass('active');

        getDashboardTab(companyId, teamId);
    });

    $("#team-dashboard-page-two").on("click", function() {
        $("#team-demands-info").hide();
        $("#team-dashboard-info").hide();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();

        $("#team-demands-tab").removeClass('active');
        $("#team-dashboard-page-two").addClass('active');

        getDashboardPageTwo(companyId, teamId);
    });
}
