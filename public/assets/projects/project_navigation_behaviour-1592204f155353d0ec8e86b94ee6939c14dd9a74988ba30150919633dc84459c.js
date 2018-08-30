hideAllComponents();

var stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

var company_id = $("#company_id").val();
var project_id = $("#project_id").val();
var projects_ids = $("#projects_ids").val();
var target_name = $("#target_name").val();

$('.nav-item').on('click', function(event){
    hideAllComponents();
    var disabled = $(this).attr('disabled');
    var period = $('#status-report-period').val();

    if (disabled === 'disabled') {
        event.preventDefault();
    } else {
        disableTabs();

        if ($(this).attr('id') === 'nav-item-statusreport') {
            buildStatusReportCharts(company_id, projects_ids, period)

        } else if ($(this).attr('id') === 'nav-item-charts') {
            buildOperationalCharts(company_id, projects_ids, period, target_name);

        } else if ($(this).attr('id') === 'nav-item-strategic') {
            buildStrategicCharts(company_id, projects_ids);

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
;
