const projectNavItem = $('.nav-item');
hideAllComponents(projectNavItem);

const stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

const companyId = $("#company_id").val();
const projectsIds = $("#projects_ids").val();
const targetName = $("#target_name").val();

projectNavItem.on('click', function(event){
    hideAllComponents($('.nav-item'));
    const disabled = $(this).attr('disabled');

    const startDate = $('#charts_filter_start_date').val();
    const endDate = $('#charts_filter_end_date').val();

    const period = $('#charts_filter_period').val();

    if (disabled === 'disabled') {
        event.preventDefault();
    } else {
        disableTabs();

        if ($(this).attr('id') === 'nav-item-charts') {
            buildOperationalCharts(companyId, projectsIds, targetName, period, startDate, endDate, "");

        } else if ($(this).attr('id') === 'nav-item-demands') {
            $('#demands-tab').hide();
            getDemands(companyId, projectsIds);

        } else if ($(this).attr('id') === 'nav-item-demands-blocks') {
            $('#demands-blocks-tab').hide();
            getDemandBlocksForProjects(companyId, projectsIds);

        } else if ($(this).attr('id') === 'nav-item-flow-impacts') {
            $('#flow-impacts-tab').hide();
            getFlowImpacts(companyId, projectsIds);

        } else if ($(this).attr('id') === 'nav-item-statistics') {
            const statsStartDate = '';
            const statsEndDate = '';
            const statsPeriod = 'month';
            const statsLeadtimeConfidence = '80';

            statisticsChartsRoute(companyId, projectsIds, statsPeriod, targetName, statsStartDate, statsEndDate, statsLeadtimeConfidence, '');

        } else {
            enableTabs();
            $($(this).data('container')).show();
        }

        $(this).addClass('active');
    }
});
