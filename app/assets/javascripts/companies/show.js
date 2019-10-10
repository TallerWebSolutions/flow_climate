hideAllComponents($('.nav-item'));

$('#nav-item-stamps').addClass('active');
$('#stamps').show();

$('#company-teams-tab').addClass('active');
$('#teams-list').show();

$("#general-loader").hide();

buildFinancesHighcharts();

projectsTableTabBehaviour();
