function bindDemandFilterActions() {
    const companyId = $("#company_id").val();
    const projectsIds = $("#projects_ids").val();

    $('.filter-checks').on('change', function(){
        filterDemands(companyId, projectsIds)
    });

    $('.filter-button').on('click', function() {
        filterDemands(companyId, projectsIds)
    });
}

function filterDemands(companyId, projectsIds) {
    $('#demands-grouped-per-month-div').hide();
    $('#demands-grouped-per-customer-div').hide();
    $('#flat-demands-div').hide();

    const flatDemands = $('#grouping_no_grouping').is(":checked");
    const groupedByMonth = $('#grouping_grouped_by_month').is(":checked");
    const groupedByCustomer = $('#grouping_grouped_by_customer').is(":checked");

    const notStarted = $('#searching_not_started').is(":checked");
    const committed = $('#searching_work_in_progress').is(":checked");
    const delivered = $('#searching_delivered_demands').is(":checked");

    const featureType = $('#demand_type_feature').is(":checked");
    const bugType = $('#demand_type_bug').is(":checked");
    const choreType = $('#demand_type_chore').is(":checked");
    const performanceImprovementType = $('#demand_type_performance_improvement').is(":checked");
    const ui = $('#demand_type_ui').is(":checked");
    const wireframe = $('#demand_type_wireframe').is(":checked");

    const standardClass = $('#demand_class_of_service_standard').is(":checked");
    const expediteClass = $('#demand_class_of_service_expedite').is(":checked");
    const fixedDateClass = $('#demand_class_of_service_fixed_date').is(":checked");
    const intangibleClass = $('#demand_class_of_service_intangible').is(":checked");

    const searchText = $('#search_text').val();

    const period = $('#demands-table-period').val();

    searchDemandsByFlowStatus(companyId, projectsIds, flatDemands, groupedByMonth, groupedByCustomer, notStarted, committed, delivered, featureType, bugType, choreType, performanceImprovementType, ui, wireframe, standardClass, expediteClass, fixedDateClass, intangibleClass, searchText, period)
}
