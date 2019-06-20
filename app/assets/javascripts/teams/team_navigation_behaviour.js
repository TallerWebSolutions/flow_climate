hideAllComponents();

const stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

const companyId = $("#company_id").val();
const teamId = $("#team_id").val();
const projectsIds = $("#projects_ids").val();
const targetName = $("#target_name").val();

$('.nav-item').on('click', function(event){
    hideAllComponents();
    const disabled = $(this).attr('disabled');

    const period = $("#period").val();

    const startDate = $('#start_date').val();
    const endDate = $('#end_date').val();

    if (disabled === 'disabled') {
        event.preventDefault();
    } else {
        disableTabs();

        if ($(this).attr('id') === 'nav-item-charts') {
            buildOperationalCharts(companyId, projectsIds, period, targetName, startDate, endDate, teamId);

        } else if ($(this).attr('id') === 'nav-item-strategic') {
            buildStrategicCharts(companyId, projectsIds, targetName);

        } else if ($(this).attr('id') === 'nav-item-demands') {
            getDemands(companyId, projectsIds);

        } else if ($(this).attr('id') === 'nav-item-demands-blocks') {
            $('#demands-blocks-tab').hide();
            getDemandBlocks(companyId, projectsIds, startDate, endDate);

        } else if ($(this).attr('id') === 'nav-item-flow-impacts') {
            $('#flow-impacts-tab').hide();
            getTeamFlowImpacts(companyId, projectsIds);

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

function hideAllComponents() {
    $('.tab-container').hide();
    $('.nav-item').removeClass('active');
}
