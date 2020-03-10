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

    $("#team-replenishing-tab").on("click", function() {
        hideAllTeamTabs();

        let companyId = $("#company_id").val();
        let teamId = $("#team_id").val();

        activateTab($("#team-replenishing-tab"));

        buildReplenishingMeeting(companyId, teamId);
    });

    $('.dashboard-filter-button').on('click', function() {
        const companyId = $("#company_id").val();
        const teamId = $("#team_id").val();
        const startDate = $("#demands_start_date").val();
        const endDate = $("#demands_end_date").val();
        const projectStatus = $("#project_status").val();
        const demandsType = $("#demands-table-demand-type").val();
        const demandsClassOfService = $("#demands-table-class-of-service").val();
        const demandStatus = $("#demand_status").val();

        hideAllTeamTabs();

        searchDashboard(companyId, teamId, projectStatus, demandStatus, demandsType, demandsClassOfService, startDate, endDate);
    });
}

function hideAllTeamTabs(){
    $("#team-demands-info").hide();
    $("#dashboard-controls").hide();
    $("#team-dashboard-container-page-one").hide();
    $("#team-dashboard-container-page-two").hide();
    $("#team-dashboard-container-page-three").hide();
    $("#team-replenishing-container").hide();
}

function activateTab(tabToActivate) {
    $(".tablinks").removeClass("active");
    tabToActivate.addClass("active")
}
