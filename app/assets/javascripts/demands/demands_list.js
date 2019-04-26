$("#general-loader").hide();

bindDemandFilterActions();
buildDemandsTabCharts();

$('#demands-table-list').addClass("btn-active");

$('#demands-grouped-per-month-div').hide();
$('#demands-grouped-per-customer-div').hide();
$('#demands-grouped-per-stage-div').hide();
$('#content-charts').hide();
$('#flat-demands-div').show();

function buildDemandsTabCharts() {
    var demandsThroughputDiv = $('#demands-throughput-column');
    if (demandsThroughputDiv.length !== 0) {
        buildColumnChart(demandsThroughputDiv);
    }

    var demandsCreatedDiv = $('#demands-created-column');
    if (demandsCreatedDiv.length !== 0) {
        buildColumnChart(demandsCreatedDiv);
    }

    var demandsCommittedDiv = $('#demands-committed-column');
    if (demandsCommittedDiv.length !== 0) {
        buildColumnChart(demandsCommittedDiv);
    }

    var leadtimeEvolution = $('#leadtime-evolution');
    if (leadtimeEvolution.length !== 0) {
        buildLineChart(leadtimeEvolution);
    }
}