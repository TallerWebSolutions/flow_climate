function buildStatisticsCharts() {
    const scopeGrowthInTime = $('#area-scope-growth');
    buildAreaChart(scopeGrowthInTime);

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated');
    buildLineChart(lineLeadtimeAccumulated);

    const lineBlocksAccumulated = $('#line-blocks-accumalated');
    buildLineChart(lineBlocksAccumulated);

    const lineStatsPopulationDataRange = $('#line-lead-time-data-range-evolution');
    if (lineStatsPopulationDataRange.length !== 0) {
        buildLineChart(lineStatsPopulationDataRange);
    }

    const lineHistogramDataRangeEvolution = $('#line-histogram-data-range-evolution');
    if (lineHistogramDataRangeEvolution.length !== 0) {
        buildLineChart(lineHistogramDataRangeEvolution);
    }

    const lineLeadTimeInterQuartileDataRange = $('#line-lead-time-interquartile-data-range');
    if (lineLeadTimeInterQuartileDataRange.length !== 0) {
        buildLineChart(lineLeadTimeInterQuartileDataRange);
    }

    const lineLeadTimeInterquartileHistogramRange = $('#line-lead-time-interquartile-histogram-range');
    if (lineLeadTimeInterquartileHistogramRange.length !== 0) {
        buildLineChart(lineLeadTimeInterquartileHistogramRange);
    }
}
;
