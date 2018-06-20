hideAllComponents();
$('#stamps').show();

var stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');

var company_id = $("#company_id").val();
var team_id = $("#team_id").val();

$(".loader").hide();

stampsDiv.on('click', function(){
    hideAllComponents();
    $('#stamps').show();
    $('#nav-item-stamps').addClass('active');
});

$('#nav-item-list').on('click', function(){
    hideAllComponents();
    $('#project-list').show();
    $('#nav-item-list').addClass('active');
});

$('#nav-item-delivered').on('click', function(){
    hideAllComponents();
    $('#demands-list').show();
    $('#nav-item-delivered').addClass('active');
});

$('#nav-item-statusreport').on('click', function(){
    hideAllComponents();
    disableTabs();

    buildStatusReportCharts(company_id, team_id)
});

$('#nav-item-charts').on('click', function(){
    hideAllComponents();
    disableTabs();

    buildOperationalCharts(company_id, team_id);
});
$('#nav-item-strategic').on('click', function(){
    hideAllComponents();
    disableTabs();

    buildStrategicCharts(company_id, team_id);
});

$('#nav-item-members').on('click', function(){
    hideAllComponents();
    $('#members-table').show();
    $('#nav-item-members').addClass('active');
});

$('#nav-item-flow').on('click', function(){
    hideAllComponents();
    disableTabs();
    searchDemandsToFlowCharts(company_id, team_id, ISO8601_week_no(new Date()), (new Date()).getFullYear());
});

$('#nav-item-settings').on('click', function(){
    hideAllComponents();
    $('#settings').show();
    $('#nav-item-settings').addClass('active');
});

function hideAllComponents() {
    $('#stamps').hide();
    $('#project-list').hide();
    $('#demands-list').hide();
    $('#project-status-report').hide();
    $('#charts').hide();
    $('#strategic').hide();
    $('#members-table').hide();
    $('#settings').hide();
    $('#flow').hide();

    $('#nav-item-stamps').removeClass('active');
    $('#nav-item-list').removeClass('active');
    $('#nav-item-delivered').removeClass('active');
    $('#nav-item-statusreport').removeClass('active');
    $('#nav-item-charts').removeClass('active');
    $('#nav-item-strategic').removeClass('active');
    $('#nav-item-members').removeClass('active');
    $('#nav-item-settings').removeClass('active');
    $('#nav-item-flow').removeClass('active');
}

accordionBehaviour();
