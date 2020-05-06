function buildStatisticsCharts() {
    const scopeGrowthInTime = $('#area-scope-growth');
    if (scopeGrowthInTime.length !== 0) {
        buildAreaChart(scopeGrowthInTime);
    }

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated');
    if (lineLeadtimeAccumulated.length !== 0) {
        buildLineChart(lineLeadtimeAccumulated);
    }

    const lineBlocksAccumulated = $('#line-blocks-accumalated');
    if (lineBlocksAccumulated.length !== 0) {
        buildLineChart(lineBlocksAccumulated);
    }

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
};
