const projectLeadTimeRange = $('#project-lead-time-data-range-evolution-line');
if (projectLeadTimeRange.length !== 0) {
    buildLineChart(projectLeadTimeRange);
}

const projectHistogramRange = $('#project-histogram-data-range-evolution-line');
if (projectHistogramRange.length !== 0) {
    buildLineChart(projectHistogramRange);
}

const projectInterquartileRange = $('#project-interquartile-data-range-evolution-line');
if (projectInterquartileRange.length !== 0) {
    buildLineChart(projectInterquartileRange);
};
