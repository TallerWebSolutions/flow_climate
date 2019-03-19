function buildStatisticsCharts() {
    const scopeGrowthInTime = $('#area-scope-growth');
    buildAreaChart(scopeGrowthInTime);

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated');
    buildLineChart(lineLeadtimeAccumulated);

    const lineBlocksAccumulated = $('#line-blocks-accumalated');
    buildLineChart(lineBlocksAccumulated);
}
