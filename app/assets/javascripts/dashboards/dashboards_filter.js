$('.dashboard-filter-button').on('click', function() {
    const companyId = $("#company_id").val();
    const teamId = $("#team_id").val();
    const startDate = $("#demands_start_date").val();
    const endDate = $("#demands_end_date").val();
    const projectStatus = $("#project_status").val();
    const demandsType = $("#demands-table-demand-type").val();
    const demandsClassOfService = $("#demands-table-class-of-service").val();

    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/dashboard_search.js`,
        type: "GET",
        data: `&project_status=${projectStatus}&demand_type=${demandsType}&demand_class_of_service=${demandsClassOfService}&start_date=${startDate}&end_date=${endDate}`
    });
});
