$('#general-loader').hide();

$('.portfolio-unit-demands-tab').addClass('active');
$('#portfolio-unit-demands').show();

$('#demands-charts-div').show();

buildDemandsTabCharts();

$('#search-charts').on('click', function() {
    $('#demands-charts-div').hide();

    const companyId = $("#company_id").val();
    const productId = $("#product_id").val();

    const period = $('#charts_filter_period').val();
    const startDate = $('#charts_filter_start_date').val();
    const endDate = $('#charts_filter_end_date').val();

    searchPortfolioChartsTab(companyId, productId, startDate, endDate, period)
});
