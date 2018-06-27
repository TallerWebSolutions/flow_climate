hideAllComponents();

var stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

var company_id = $("#company_id").val();
var team_id = $("#team_id").val();

$('.nav-item').on('click', function(event){
    hideAllComponents();
    var disabled = $(this).attr('disabled');
    var period = $('#status-report-period').val();

    if (disabled === 'disabled') {
        event.preventDefault();
    } else {
        disableTabs();

        if ($(this).attr('id') === 'nav-item-statusreport') {
            buildStatusReportCharts(company_id, team_id, period)

        } else if ($(this).attr('id') === 'nav-item-charts') {
            buildOperationalCharts(company_id, team_id);

        } else if ($(this).attr('id') === 'nav-item-strategic') {
            buildStrategicCharts(company_id, team_id);

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
