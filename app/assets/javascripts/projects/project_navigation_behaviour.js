hideAllComponents();

var stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

const companyId = $("#company_id").val();
const projectId = $("#project_id").val();
const projectsIds = $("#projects_ids").val();
const targetName = $("#target_name").val();

$('.nav-item').on('click', function(event){
    hideAllComponents();
    const disabled = $(this).attr('disabled');
    const period = $('#status-report-period').val();

    if (disabled === 'disabled') {
        event.preventDefault();
    } else {
        disableTabs();

        if ($(this).attr('id') === 'nav-item-statusreport') {

            buildStatusReportCharts(companyId, projectsIds, period, targetName)
        } else if ($(this).attr('id') === 'nav-item-charts') {

            buildOperationalCharts(companyId, projectsIds, period, targetName);
        } else if ($(this).attr('id') === 'nav-item-strategic') {

            buildStrategicCharts(companyId, projectsIds, targetName);
        } else if ($(this).attr('id') === 'nav-item-demands') {
            $('#demands-tab').hide();

            getDemands(companyId, projectsIds);
        } else if ($(this).attr('id') === 'nav-item-statistics') {
            $('#demands-tab').hide();

            getProjectStatistics(companyId, projectId, $("#start_date").val(), $("#end_date").val(), $("#period").val());
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
