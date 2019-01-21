function bindDemandFilterActions() {
    const companyId = $("#company_id").val();
    const projectsIds = $("#projects_ids").val();

    $('.filter-checks').on('change', function(){
        $('#demands-grouped-per-month-div').hide();
        $('#demands-grouped-per-customer-div').hide();
        $('#flat-demands-div').hide();

        const flatDemands = $('#grouping_no_grouping').is(":checked");
        const groupedByMonth = $('#grouping_grouped_by_month').is(":checked");
        const groupedByCustomer = $('#grouping_grouped_by_customer').is(":checked");

        const notStarted = $('#searching_not_started').is(":checked");
        const committed = $('#searching_work_in_progress').is(":checked");
        const delivered = $('#searching_delivered_demands').is(":checked");

        const period = $('#demands-table-period').val();

        searchDemandsByFlowStatus(companyId, projectsIds, flatDemands, groupedByMonth, groupedByCustomer, notStarted, committed, delivered, period)
    });
}
