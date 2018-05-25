hideAllComponents();
$('#stamps').show();
$('#nav-item-stamps').addClass('active');
buildOperationalHighcharts();
buildStatusReportCurrentCharts();

$('#nav-item-stamps').on('click', function(){
    hideAllComponents();
    $('#stamps').show();
    $('#nav-item-stamps').addClass('active');
});

$('#nav-item-list').on('click', function(){
    hideAllComponents();
    $('#project-list').show();
    $('#nav-item-list').addClass('active');
});

$('#nav-item-statusreport').on('click', function(){
    hideAllComponents();
    $('#project-status-report').show();
    $('#nav-item-statusreport').addClass('active');
});

$('#nav-item-charts').on('click', function(){
    hideAllComponents();
    $('#charts').show();
    $('#nav-item-charts').addClass('active');
});

function hideAllComponents() {
    $('#stamps').hide();
    $('#project-list').hide();
    $('#project-status-report').hide();
    $('#charts').hide();

    $('#nav-item-stamps').removeClass('active');
    $('#nav-item-list').removeClass('active');
    $('#nav-item-statusreport').removeClass('active');
    $('#nav-item-charts').removeClass('active');
}