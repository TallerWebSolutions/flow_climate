function activateTab() {
    var navItem = $('.nav-item');
    navItem.on('click', function(){
        hideAllComponents(navItem);

        $(this).addClass('active');

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

        if ($(this).attr('id') === 'nav-item-settings') {
            document.getElementsByClassName("company-config-tab")[0].className += " active";
            document.getElementById("company-settings").style.display = "block";
        }
    });
}
;
