function bindDashboardSelectors() {
    $("#team-demands-tab").on("click", function() {
        $("#team-dashboard-container-page-one").hide();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();

        $("#team-dashboard-tab").removeClass('active');
        $("#team-demands-tab").addClass('active');

        $('#page-buttons').hide();

        getDemandsTab(companyId, teamId, demandsIds);
    });

    $("#team-dashboard-tab, #team-dashboard-page-one").on("click", function() {
        $("#team-dashboard-container-page-two").hide();
        $("#team-dashboard-container-page-three").hide();
        $("#team-demands-info").hide();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();

        $("#team-demands-tab").removeClass('active');
        $("#team-dashboard-page-two").removeClass('active');
        $("#team-dashboard-page-three").removeClass('active');
        $("#team-dashboard-tab").addClass('active');

        getDashboardTab(companyId, teamId, demandsIds);
    });

    $("#team-dashboard-page-two").on("click", function() {
        $("#team-demands-info").hide();
        $("#team-dashboard-container-page-one").hide();
        $("#team-dashboard-container-page-two").hide();
        $("#team-dashboard-container-page-three").hide();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();
        let startDate = $("#demands_start_date").val();
        let endDate = $("#demands_end_date").val();

        $("#team-demands-tab").removeClass('active');
        $("#team-dashboard-page-three").removeClass('active');
        $("#team-dashboard-page-two").addClass('active');

        getDashboardPageTwo(companyId, teamId, demandsIds, startDate, endDate);
    });

    $("#team-dashboard-page-three").on("click", function() {
        $("#team-demands-info").hide();
        $("#team-dashboard-container-page-one").hide();
        $("#team-dashboard-container-page-two").hide();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();
        let startDate = $("#demands_start_date").val();
        let endDate = $("#demands_end_date").val();

        $("#team-demands-tab").removeClass('active');
        $("#team-dashboard-page-two").removeClass('active');
        $("#team-dashboard-page-three").addClass('active');

        getDashboardPageThree(companyId, teamId, demandsIds, startDate, endDate);
    });
}
