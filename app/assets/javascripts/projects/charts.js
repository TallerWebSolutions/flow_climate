$(function () {
    var throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    var burnupDemands = $('#burnup-demands');
    buildBurnupChart(burnupDemands);

    var flowPressureDiv = $('#flowpressure-column');
    buildColumnChart(flowPressureDiv);

    var cmdDiv = $('#cmd-column');
    buildColumnChart(cmdDiv);
});
