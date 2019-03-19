hideAllComponents();

const stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

const companyId = $("#company_id").val();
const teamId = $("#team_id").val();
const projects_ids = $("#projects_ids").val();
const target_name = $("#target_name").val();

$('.nav-item').on('click', function(event){
    hideAllComponents();
    const disabled = $(this).attr('disabled');
    const period = $('#status-report-period').val();

    if (disabled === 'disabled') {
        event.preventDefault();
    } else {
        disableTabs();
        if ($(this).attr('id') === 'nav-item-statusreport') {
            buildStatusReportCharts(companyId, projects_ids, period, target_name)

        } else if ($(this).attr('id') === 'nav-item-charts') {
            buildOperationalCharts(companyId, projects_ids, period, target_name);

        } else if ($(this).attr('id') === 'nav-item-strategic') {
            buildStrategicCharts(companyId, projects_ids, target_name);

        } else if ($(this).attr('id') === 'nav-item-demands') {
            getDemands(companyId, projects_ids);

        } else if ($(this).attr('id') === 'nav-item-replenishingDiv') {
            buildReplenishingMeeting(companyId, teamId);

        } else if ($(this).attr('id') === 'nav-item-statistics') {
            getTeamStatistics(companyId, teamId, $("#start_date").val(), $("#end_date").val(), $("#period").val());

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
