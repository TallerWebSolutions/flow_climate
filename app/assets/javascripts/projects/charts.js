$(function () {
    var throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    var bugsInTimeDiv = $('#bugs-in-time');
    buildColumnChart(bugsInTimeDiv);

    var shareBugsInTimeDiv = $('#line-share-bug');
    buildLineChart(shareBugsInTimeDiv);

    var queueTouchCountDiv = $('#queue-touch-in-time');
    buildColumnChart(queueTouchCountDiv);

    var flowEfficiencyDiv = $('#flow-efficiency-bug');
    buildLineChart(flowEfficiencyDiv);

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
