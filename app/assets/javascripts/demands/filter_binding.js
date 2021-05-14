function filterDemands(companyId, demandsIds) {
    $('#demands-grouped-per-month-div').hide();
    $('#demands-grouped-per-customer-div').hide();
    $('#demands-grouped-per-stage-div').hide();
    $('#flat-demands-div').hide();
    $('#demand-tab-content').hide();
    $('#list-charts-button').hide();

    const demandState = $('#demands-table-flow-status').val();
    const demandType = $('#demands-table-demand-type').val();
    const demandClassOfService = $('#demands-table-class-of-service').val();

    const searchText = $('#search_text').val();
    const searchDemandTags = $('#search-demand-tags').val();

    const start_date = $('#demands_start_date').val();
    const end_date = $('#demands_end_date').val();

    searchDemands(companyId, demandsIds, demandState, demandType, demandClassOfService, searchText, start_date, end_date, searchDemandTags)
}
