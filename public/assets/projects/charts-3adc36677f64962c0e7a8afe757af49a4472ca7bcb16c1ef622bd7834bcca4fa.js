const leadTimeP80Div = $("#project-dashboard-lead-time-line");
buildLineChart(leadTimeP80Div);

const projectQuality = $("#project-dashboard-quality-line");
if (projectQuality.length !== 0) {
    buildLineChart(projectQuality);
}

const projectHoursPerDemand = $("#project-dashboard-hours-per-demand-line");
if (projectHoursPerDemand.length !== 0) {
    buildLineChart(projectHoursPerDemand);
}

const projectFlowEfficiency = $("#project-dashboard-flow-efficiency-line");
if (projectFlowEfficiency.length !== 0) {
    buildLineChart(projectFlowEfficiency);
}

const projectBurnup = $("#project-burnup-demands");
if (projectBurnup.length !== 0) {
    buildLineChart(projectBurnup);
}

const projectBurnupHours = $("#project-burnup-hours");
if (projectBurnupHours.length !== 0) {
    buildLineChart(projectBurnupHours);
}

const projectBugsColumn = $("#project-dashboard-bugs-column");
if (projectBugsColumn.length !== 0) {
    buildColumnChart(projectBugsColumn);
}

const projectFlowDataColumn = $("#project-dashboard-flow-data-column");
if (projectFlowDataColumn.length !== 0) {
    buildColumnChart(projectFlowDataColumn);
}

const projectLeadtimeControlChart = $("#project-leadtime-control-chart");
if (projectLeadtimeControlChart.length !== 0) {
    buildScatterChart(projectLeadtimeControlChart);
}

const projectLeadtimeHistogramChart = $("#project-leadtime-histogram");
if (projectLeadtimeHistogramChart.length !== 0) {
    buildColumnChart(projectLeadtimeHistogramChart);
}

const projectCfd = $("#project-cfd-downstream-area");
if (projectCfd.length !== 0) {
    buildAreaChart(projectCfd);
}

const projectQualityBugs = $("#project-dashboard-quality-blocks-line");
if (projectQualityBugs.length !== 0) {
    buildLineChart(projectQualityBugs);
}

const projectQualityBlockPerDemand = $("#project-dashboard-quality-blocks-per-demand-line");
if (projectQualityBlockPerDemand.length !== 0) {
    buildLineChart(projectQualityBlockPerDemand);
}

const projectHoursConsumed = $("#project-dashboard-hours-per-demand-column-line");
if (projectHoursConsumed.length !== 0) {
    buildColumnLineChart(projectHoursConsumed);
};
