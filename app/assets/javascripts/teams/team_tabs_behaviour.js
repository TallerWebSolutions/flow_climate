function bindDashboardSelectors() {
    $("#team-demands-tab").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();

        activateTab($("#team-demands-tab"));

        $('#page-buttons').hide();

        getDemandsTab(companyId, teamId, demandsIds);
    });

    $("#team-dashboard-tab, #team-dashboard-page-one").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();

        activateTab($("#team-dashboard-tab"));

        getDashboardTab(companyId, teamId, demandsIds);
    });

    $("#team-dashboard-page-two").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();
        let startDate = $("#demands_start_date").val();
        let endDate = $("#demands_end_date").val();

        activateTab($("#team-dashboard-page-two"));

        getDashboardPageTwo(companyId, teamId, demandsIds, startDate, endDate);
    });

    $("#team-dashboard-page-three").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();
        let startDate = $("#demands_start_date").val();
        let endDate = $("#demands_end_date").val();

        activateTab($("#team-dashboard-page-three"));

        getDashboardPageThree(companyId, teamId, demandsIds, startDate, endDate);
    });

    $("#team-dashboard-page-four").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();
        let demandsIds = $('#demands_ids').val();
        let startDate = $("#demands_start_date").val();
        let endDate = $("#demands_end_date").val();

        getDashboardPageFour(companyId, teamId, demandsIds, startDate, endDate);
    });

    $("#team-dashboard-page-five").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();

        getDashboardPageFive(companyId, teamId);
    });

    $("#team-replenishing-tab").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();

        activateTab($("#team-replenishing-tab"));

        buildReplenishingMeeting(companyId, teamId);
    });

    $("#team-projects-tab").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();

        activateTab($("#team-projects-tab"));

        getTeamProjectsTab(companyId, teamId);
    });
}

function hideAllTeamTabs(){
    $("#team-demands-info").hide();
    $("#team-projects-charts").hide();
    $("#dashboard-controls").hide();
    $("#team-dashboard-filters").hide();

    $("#team-dashboard-container-page-one").hide();
    $("#team-dashboard-container-page-two").hide();
    $("#team-dashboard-container-page-three").hide();
    $("#team-dashboard-container-page-four").hide();
    $("#team-dashboard-container-page-five").hide();
    $("#team-replenishing-container").hide();
}

function activateTab(tabToActivate) {
    $(".tablinks").removeClass("active");
    tabToActivate.addClass("active")
}
