hideAllComponents();

const stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

const company_id = $("#company_id").val();
const team_id = $("#team_id").val();
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
            buildStatusReportCharts(company_id, projects_ids, period, target_name)

        } else if ($(this).attr('id') === 'nav-item-charts') {
            buildOperationalCharts(company_id, projects_ids, period, target_name);

        } else if ($(this).attr('id') === 'nav-item-strategic') {
            buildStrategicCharts(company_id, projects_ids, target_name);

        } else if ($(this).attr('id') === 'nav-item-delivered') {
            getDemands(company_id, projects_ids);

        } else {
            showClicked($(this).data('container'), $(this));
            enableTabs();
        }
    }
});

function showClicked(containerId, navItem) {
    $(containerId).show();
    navItem.addClass('active');
}

function hideAllComponents() {
    $('.tab-container').hide();
    $('.nav-item').removeClass('active');
}
