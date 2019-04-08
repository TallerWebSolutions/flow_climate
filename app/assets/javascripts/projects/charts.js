function buildOperationalHighcharts() {
    const throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    const accBugsInTimeDiv = $('#accumulated-bugs-in-time');
    buildColumnChart(accBugsInTimeDiv);

    const accShareBugsInTimeDiv = $('#accumulated-share-bug');
    buildLineChart(accShareBugsInTimeDiv);

    const bugsInTimeDiv = $('#bugs-in-time');
    buildColumnChart(bugsInTimeDiv);

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

    const hoursBlockedPerStageDiv = $('#hours-blocked-per-stage');
    if (hoursBlockedPerStageDiv.length !== 0) {
        buildColumnChart(hoursBlockedPerStageDiv);
    }

    const agingPerDemandDiv = $('#aging-per-demand-div');
    if (agingPerDemandDiv.length !== 0) {
        buildColumnChart(agingPerDemandDiv);
    }
}
