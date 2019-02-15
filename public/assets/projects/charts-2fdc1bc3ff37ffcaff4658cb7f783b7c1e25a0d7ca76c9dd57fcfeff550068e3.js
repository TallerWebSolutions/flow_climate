function buildOperationalHighcharts() {
    const throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    const bugsInTimeDiv = $('#bugs-in-time');
    buildColumnChart(bugsInTimeDiv);

    const shareBugsInTimeDiv = $('#line-share-bug');
    buildLineChart(shareBugsInTimeDiv);

    const queueTouchCountDiv = $('#queue-touch-in-time');
    buildColumnChart(queueTouchCountDiv);

    const flowEfficiencyDiv = $('#flow-efficiency');
    buildLineChart(flowEfficiencyDiv);

    const hoursPerDemandDiv = $('#hours-column');
    buildColumnChart(hoursPerDemandDiv);

    const burnupDemands = $('#burnup-demands');
    buildBurnupChart(burnupDemands);

    const flowPressureDiv = $('#flowpressure-column');
    buildColumnChart(flowPressureDiv);

    const leadtimeControlChart = $('#leadtime-control-chart');
    buildScatterChart(leadtimeControlChart);

    const leadtimeHistogramChart = $('#leadtime-histogram');
    buildColumnChart(leadtimeHistogramChart);

    const throughputHistogramChart = $('#throughput-histogram');
    buildColumnChart(throughputHistogramChart);

    const hoursConsumedColumnDiv = $('#hours-consumed-column');
    buildColumnChart(hoursConsumedColumnDiv);
}
;
