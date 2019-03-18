function buildProjectStatistics() {
    const scopeGrowthInTime = $('#area-scope-growth');
    buildAreaChart(scopeGrowthInTime);

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated');
    buildLineChart(lineLeadtimeAccumulated);
}
