function filterTeamDemands() {
    hideAllTeamTabs();

    const demandState = $('#demands-table-flow-status').val();
    const demandType = $('#demands-table-demand-type').val();
    const demandClassOfService = $('#demands-table-class-of-service').val();

    const searchText = $('#search_text').val();
    const searchDemandTags = $('#search-demand-tags').val();
    const companyId = $("#company_id").val();
    const teamId = $("#team_id").val();
    const demandsIds = $("#demands_ids").val();

    const start_date = $('#demands_start_date').val();
    const end_date = $('#demands_end_date').val();

    searchTeamDemands(companyId, teamId, demandsIds, demandState, demandType, demandClassOfService, searchText, start_date, end_date, searchDemandTags)
};
