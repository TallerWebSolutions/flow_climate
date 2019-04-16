$("#general-loader").hide();

$('#search_operational_charts').on('click', function() {
    const companyId = $('#company_id').val();
    const projects_ids = $("#projects_ids").val();
    const startDate = $('#operational_charts_start_date').val();
    const endDate = $('#operational_charts_end_date').val();
    const period = $('#operational_charts_period').val();
    const targetName = $('#target_name').val();

    buildOperationalCharts(companyId, projects_ids, period, targetName, startDate, endDate, "")
});
