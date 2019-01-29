$("#general-loader").hide();

bindDemandFilterActions();

var demandsThroughputDiv = $('#demands-throughput-column');
buildColumnChart(demandsThroughputDiv);

var demandsCreatedDiv = $('#demands-created-column');
buildColumnChart(demandsCreatedDiv);

var demandsCommittedDiv = $('#demands-committed-column');
buildColumnChart(demandsCommittedDiv);

$('#demands-table-list').addClass("btn-active");

$('#demands-grouped-per-month-div').hide();
$('#demands-grouped-per-customer-div').hide();
$('#flat-demands-div').show();
$('#content-charts').hide();
