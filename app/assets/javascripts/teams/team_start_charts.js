function startCharts() {
    const statusReportCFDDownstreamDiv = $('#cfd-downstream-area');
    buildAreaChart(statusReportCFDDownstreamDiv);

    const leadtimeHistogramChart = $('#leadtime-histogram');
    buildHistogramChart(leadtimeHistogramChart);

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated');
    buildLineChart(lineLeadtimeAccumulated);

    const lineBugsAccumulated = $('#line-bug-share-accumalated');
    buildColumnLineChart(lineBugsAccumulated);

    const columnBugsMonth = $('#column-bug-opened-closed-month');
    buildColumnChart(columnBugsMonth);

    const throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    const leadtimeControlChart = $('#leadtime-control-chart');
    buildScatterChart(leadtimeControlChart);

    const flowEfficiencyDiv = $('#flow-efficiency');
    buildLineChart(flowEfficiencyDiv);

    const leadTimeZonesDonut = $('#lead-time-zones-donut');
    buildDonutChart(leadTimeZonesDonut);

    const teamTagsWordCount = $('#team-tags-word-count');
    buildWordCloudChart(teamTagsWordCount);
}
