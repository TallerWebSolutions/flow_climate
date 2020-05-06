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

    const leadtimeControlChart = $('#leadtime-control-chart');
    buildScatterChart(leadtimeControlChart);

    const leadtimeHistogramChart = $('#leadtime-histogram');
    buildColumnChart(leadtimeHistogramChart);

    const hoursConsumedColumnDiv = $('#hours-consumed-column');
    buildColumnChart(hoursConsumedColumnDiv);

    const hoursBlockedPerStageDiv = $('#hours-blocked-per-stage');
    if (hoursBlockedPerStageDiv.length !== 0) {
        buildColumnChart(hoursBlockedPerStageDiv);
    }

    const countBlockedPerStageDiv = $('#count-blocked-per-stage');
    if (countBlockedPerStageDiv.length !== 0) {
        buildColumnChart(countBlockedPerStageDiv);
    }

    const agingPerDemandDiv = $('#aging-per-demand-div');
    if (agingPerDemandDiv.length !== 0) {
        buildColumnChart(agingPerDemandDiv);
    }

    const avgDemandCost = $('#average-demand-cost');
    if (avgDemandCost.length !== 0) {
        buildLineChart(avgDemandCost);
    }

    const hoursEfficiency = $('#hours-efficiency');
    if (hoursEfficiency.length !== 0) {
        buildLineChart(hoursEfficiency);
    }

    const scopeUncertainty = $('#operational-charts-scope-uncertainty-donut');
    if (scopeUncertainty.length !== 0) {
        buildDonutChart(scopeUncertainty);
    }

    let columnFlowDataDiv = $('#operational-charts-flow-data-column');
    if (columnFlowDataDiv.length !== 0) {
        buildColumnChart(columnFlowDataDiv);
    }
};
