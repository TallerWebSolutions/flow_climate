function startCharts() {
    const statusReportCFDDownstreamDiv = $('#cfd-downstream-area');
    buildAreaChart(statusReportCFDDownstreamDiv);

    const leadtimeHistogramChart = $('#leadtime-histogram');
    buildHistogramChart(leadtimeHistogramChart);

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated');
    buildLineChart(lineLeadtimeAccumulated);

    const lineBugsAccumulated = $('#line-bug-share-accumalated');
    buildLineChart(lineBugsAccumulated);

    const avgDemandCost = $('#average-demand-cost');
    buildLineChart(avgDemandCost);

    const burnupDemands = $('#burnup-demands');
    buildLineChart(burnupDemands);

    const throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);
}
