function bindDemandFilterActions() {
    const companyId = $("#company_id").val();
    const projectsIds = $("#projects_ids").val();

    $('.filter-button').on('click', function() {
        filterDemands(companyId, projectsIds)
    });
}

function filterDemands(companyId, projectsIds) {
    $('#demands-grouped-per-month-div').hide();
    $('#demands-grouped-per-customer-div').hide();
    $('#demands-grouped-per-stage-div').hide();
    $('#flat-demands-div').hide();
    $('#demand-tab-content').hide();

    const grouping = $('#demands-table-grouping').val();
    const flowStatus = $('#demands-table-flow-status').val();
    const demandType = $('#demands-table-demand-type').val();
    const demandClassOfService = $('#demands-table-class-of-service').val();

    const searchText = $('#search_text').val();

    const start_date = $('#demands_start_date').val();
    const end_date = $('#demands_end_date').val();
    const groupingPeriod = $('#demands-table-grouping-period').val();

    searchDemandsByFlowStatus(companyId, projectsIds, grouping, flowStatus, demandType, demandClassOfService, searchText, start_date, end_date, groupingPeriod)
}
