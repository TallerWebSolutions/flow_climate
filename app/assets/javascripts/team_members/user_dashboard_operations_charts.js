function buildOperationsCharts() {
  const lineLeadtimeAccumulated = $("#line-leadtime-accumalated-user");
  if (lineLeadtimeAccumulated.length !== 0) {
    buildLineChart(lineLeadtimeAccumulated);
  }

  const linePullInterval = $("#member-dashboard-pull-interval-line");
  if (linePullInterval.length !== 0) {
    buildLineChart(linePullInterval);
  }

  const userEffortDiv = $("#member-dashboard-effort-column");
  if (userEffortDiv.length !== 0) {
    buildColumnChart(userEffortDiv);
  }

  const teamMemberThroughputDiv = $("#member-dashboard-throughput-column");
  if (teamMemberThroughputDiv.length !== 0) {
    buildColumnChart(teamMemberThroughputDiv);
  }

  const memberLeadTimeControlChart = $("#member-lead-time-control-chart");
  if (memberLeadTimeControlChart.length !== 0) {
    buildScatterChart(memberLeadTimeControlChart);
  }

  const memberLeadTimeHistogram = $("#member-lead-time-histogram");
  if (memberLeadTimeHistogram.length !== 0) {
    buildColumnChart(memberLeadTimeHistogram);
  }

  const teamMemberHoursPerProject = $("#member-dashboard-hours-per-project");
  if (teamMemberHoursPerProject.length !== 0) {
    buildColumnChart(teamMemberHoursPerProject);
  }
}
