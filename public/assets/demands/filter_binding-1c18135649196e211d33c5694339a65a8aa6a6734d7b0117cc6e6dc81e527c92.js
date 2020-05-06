function bindDemandFilterActions() {
    const companyId = $("#company_id").val();
    const demandsIds = $("#demands_ids").val();

    $('.filter-button').on('click', function() {
        filterDemands(companyId, demandsIds)
    });
}

function filterDemands(companyId, demandsIds) {
    $('#demands-grouped-per-month-div').hide();
    $('#demands-grouped-per-customer-div').hide();
    $('#demands-grouped-per-stage-div').hide();
    $('#flat-demands-div').hide();
    $('#demand-tab-content').hide();
    $('#list-charts-button').hide();

    const grouping = $('#demands-table-grouping').val();
    const flowStatus = $('#demands-table-flow-status').val();
    const demandType = $('#demands-table-demand-type').val();
    const demandClassOfService = $('#demands-table-class-of-service').val();

    const searchText = $('#search_text').val();

    const start_date = $('#demands_start_date').val();
    const end_date = $('#demands_end_date').val();
    const groupingPeriod = $('#demands-table-grouping-period').val();

    searchDemands(companyId, demandsIds, grouping, flowStatus, demandType, demandClassOfService, searchText, start_date, end_date, groupingPeriod)
};
