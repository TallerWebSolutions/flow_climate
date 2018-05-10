$(function () {
    var burnupHours = $('#burnup-hours');
    buildBurnupChart(burnupHours);

    var statusReportThroughputDiv = $('#status-report-throughput-column');
    buildColumnChart(statusReportThroughputDiv);

    var statusReportDeliveredDiv = $('#status-report-delivered-column');
    buildColumnChart(statusReportDeliveredDiv);

    var statusReportDeadlineDiv = $('#status-report-deadline-bar');
    buildBarChart(statusReportDeadlineDiv);

    var statusReportHoursDiv = $('#status-report-hours-column');
    buildColumnChart(statusReportHoursDiv);
});
