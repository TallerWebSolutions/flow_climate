hideAllComponents();

function activateTab() {
    $('.nav-item').on('click', function(){
        hideAllComponents();

        const companyId = $('#company_id').val();

        if ($(this).attr('id') === 'nav-item-risks') {
            getRisksTab(companyId);

        } else if ($(this).attr('id') === 'nav-item-projects-list') {
            getCompanyProjectsTab(companyId);

        } else if ($(this).attr('id') === 'nav-item-strategic-charts') {
            getStrategicChartsTab(companyId);

        } else {
            $($(this).data('container')).show();
            enableTabs();

            $("#general-loader").hide();
        }

        $(this).addClass('active');
    });
}

function hideAllComponents() {
    $('.tab-container').hide();
    $('.nav-item').removeClass('active');
}
