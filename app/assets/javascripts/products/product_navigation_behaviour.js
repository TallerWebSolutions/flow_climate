const navItem = $('.nav-item');

hideAllComponents(navItem);

const stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');

$('#stamps').show();

navItem.on('click', function(event){
    hideAllComponents(navItem);
    const disabled = $(this).attr('disabled');

    const companyId = $("#company_id").val();
    const productId = $("#product_id").val();

    if (disabled === 'disabled') {
        event.preventDefault();

    } else {
        disableTabs();

        if ($(this).attr('id') === 'nav-portfolio-unit') {
            getProductPortfolioUnitsTab(companyId, productId)

        } else if ($(this).attr('id') === 'nav-projects-table') {
            $('.col-table-details').hide();
            getProjectsTab(companyId, productId)

        } else if ($(this).attr('id') === 'nav-portfolio-demands') {
            $('.col-table-details').hide();
            getPortfolioDemandsTab(companyId, productId)

        } else if ($(this).attr('id') === 'nav-portfolio-charts') {
            $('.col-table-details').hide();
            getPortfolioChartsTab(companyId, productId)

        } else {
            enableTabs();
            $($(this).data('container')).show();
        }

        $(this).addClass('active');
    }
});
