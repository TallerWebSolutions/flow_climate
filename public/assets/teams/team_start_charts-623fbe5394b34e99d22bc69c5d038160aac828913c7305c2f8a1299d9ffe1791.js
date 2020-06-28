function startCharts() {
    const statusReportCFDDownstreamDiv = $('#cfd-downstream-area');
    buildAreaChart(statusReportCFDDownstreamDiv);

    const leadtimeHistogramChart = $('#leadtime-histogram');
    buildHistogramChart(leadtimeHistogramChart);

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated');
    buildLineChart(lineLeadtimeAccumulated);

    const lineBugsAccumulated = $('#line-bug-share-accumalated');
    buildLineChart(lineBugsAccumulated);

    const burnupDemands = $('#burnup-demands');
    buildLineChart(burnupDemands);

    const throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    const leadtimeControlChart = $('#leadtime-control-chart');
    buildScatterChart(leadtimeControlChart);

    const flowEfficiencyDiv = $('#flow-efficiency');
    buildLineChart(flowEfficiencyDiv);

    const bugsInTimeDiv = $('#bugs-in-time');
    buildColumnChart(bugsInTimeDiv);

    const leadTimeZonesDonut = $('#lead-time-zones-donut');
    buildDonutChart(leadTimeZonesDonut);

    const teamTagsWordCount = $('#team-tags-word-count');
    buildWordCloudChart(teamTagsWordCount);
};
