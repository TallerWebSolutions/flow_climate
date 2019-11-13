$("#general-loader").hide();

$('#team-dashboard-tab').addClass('active');

$('#team-dashboard-page-one').addClass('active');
$('#team-dashboard-page-two').removeClass('active');
$('#team-dashboard-page-three').removeClass('active');
$('#team-search-info-tab').addClass('active');

$("#team-dashboard-container-page-one").show();
$("#team-dashboard-container-page-two").hide();
$("#team-dashboard-container-page-three").hide();
$("#team-demands-info").hide();
$("#team-search-info").show();

$('#page-buttons').show();

startCharts();
bindDashboardSelectors();
