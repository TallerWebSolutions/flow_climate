$('.nav-item').on('click', function(event){
    hideAllComponents($('.nav-item'));

    const companyId = $("#company_id").val();
    const teamId = $("#team_id").val();
    const projectsIds = $("#projects_ids").val();
    const teamsIds = $("#teams_ids").val();
    const targetName = $("#target_name").val();

    const disabled = $(this).attr('disabled');

    const startDate = $('#default_start_date_to_filter').val();
    const endDate = $('#default_end_date_to_filter').val();

    if (disabled === 'disabled') {
        event.preventDefault();
    } else {
        disableTabs();

        if ($(this).attr('id') === 'nav-item-charts') {
            buildOperationalCharts(companyId, projectsIds, targetName, 'month', startDate, endDate, teamId);

        } else if ($(this).attr('id') === 'nav-item-strategic') {
            buildStrategicCharts(companyId, projectsIds, teamsIds, targetName, 'month', startDate, endDate);

        } else if ($(this).attr('id') === 'nav-item-demands') {
            getDemands(companyId, projectsIds);

        } else if ($(this).attr('id') === 'nav-item-demands-blocks') {
            $('#demands-blocks-tab').hide();
            getDemandBlocksForProjects(companyId, projectsIds);

        } else if ($(this).attr('id') === 'nav-item-flow-impacts') {
            $('#flow-impacts-tab').hide();
            getFlowImpacts(companyId, projectsIds);

        } else if ($(this).attr('id') === 'nav-item-replenishingDiv') {
            buildReplenishingMeeting(companyId, teamId);

        } else if ($(this).attr('id') === 'nav-item-statistics') {
            const statsStartDate = '';
            const statsEndDate = '';
            const statsPeriod = 'month';
            const statsLeadtimeConfidence = '80';
            const statsProjectStatus = 'executing';

            statisticsChartsRoute(companyId, projectsIds, statsPeriod, targetName, statsStartDate, statsEndDate, statsLeadtimeConfidence, statsProjectStatus);

        } else {
            enableTabs();
            $($(this).data('container')).show();
        }

        $(this).addClass('active');
    }
});
