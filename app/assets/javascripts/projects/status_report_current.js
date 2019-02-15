function buildStatusReportCurrentCharts() {
    const burnupHoursPerWeek = $('#burnup-hours-per-week');
    buildBurnupChart(burnupHoursPerWeek);

    const burnupHoursPerMonth = $('#burnup-hours-per-month');
    buildBurnupChart(burnupHoursPerMonth);

    const statusReportThroughputDiv = $('#status-report-throughput-column');
    buildColumnChart(statusReportThroughputDiv);

    const statusReportDeliveredDiv = $('#status-report-delivered-column');
    buildColumnChart(statusReportDeliveredDiv);

    const statusReportDeadlineDiv = $('#status-report-deadline-bar');
    buildBarChart(statusReportDeadlineDiv);

    const statusReportHoursPerStageUpstreamDiv = $('#status-report-hours-per-stage-upstream');
    buildColumnChart(statusReportHoursPerStageUpstreamDiv);

    const statusReportHoursPerStageDownstreamDiv = $('#status-report-hours-per-stage-downstream');
    buildColumnChart(statusReportHoursPerStageDownstreamDiv);

    const statusReportCFDDownstreamDiv = $('#cfd-downstream-area');
    buildAreaChart(statusReportCFDDownstreamDiv);

    const statusReportCFDUpstreamDiv = $('#cfd-upstream-area');
    buildAreaChart(statusReportCFDUpstreamDiv);
}
