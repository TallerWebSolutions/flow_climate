$('.nav-item').on('click', function(){
    hideAllComponents($('.nav-item'));
    hideAllComponents($('.nav-item'));

    let loader = $("#general-loader");
    loader.show();

    $(this).addClass('active');

    const companyId = $('#company_id').val();
    const projectsIds = $("#projects_ids").val();
    const teamsIds = $("#teams_ids").val();
    const targetName = $("#target_name").val();

    const startDate = $('#default_start_date_to_filter').val();
    const endDate = $('#default_end_date_to_filter').val();

    if ($(this).attr('id') === 'nav-item-risks') {
        getRisksTab(companyId);

    } else if ($(this).attr('id') === 'nav-item-projects-list') {
        getProjectsTab(companyId);

    } else if ($(this).attr('id') === 'nav-item-strategic-charts') {
        buildStrategicCharts(companyId, projectsIds, teamsIds, targetName, 'month', startDate, endDate);

    } else {
        enableTabs();
        $($(this).data('container')).show();

        loader.hide();
    }

    if ($(this).attr('id') === 'nav-item-settings') {
        document.getElementsByClassName("company-config-tab")[0].className += " active";
        document.getElementById("company-settings").style.display = "block";
    }
});
