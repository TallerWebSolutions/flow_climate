$("#general-loader").hide();

$('#search_operational_charts').on('click', function() {
    const companyId = $('#company_id').val();
    const projects_ids = $("#projects_ids").val();
    const startDate = $('#start_date').val();
    const endDate = $('#end_date').val();
    const period = $('#period').val();

    buildOperationalCharts(companyId, projects_ids, period, target_name, startDate, endDate)
});