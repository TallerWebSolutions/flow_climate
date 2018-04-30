$(function () {
    var throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    var hoursPerDemandDiv = $('#hours-column');
    buildColumnChart(hoursPerDemandDiv);

    var burnupDemands = $('#burnup-demands');
    buildBurnupChart(burnupDemands);

    var flowPressureDiv = $('#flowpressure-column');
    buildColumnChart(flowPressureDiv);

    var cmdDiv = $('#cmd-column');
    buildColumnChart(cmdDiv);

    var leadtimeControlChart = $('#leadtime-control-chart');
    buildScatterChart(leadtimeControlChart);

    var leadtimeHistogramChart = $('#leadtime-histogram');
    buildColumnChart(leadtimeHistogramChart);

    var throughputHistogramChart = $('#throughput-histogram');
    buildColumnChart(throughputHistogramChart);
});
