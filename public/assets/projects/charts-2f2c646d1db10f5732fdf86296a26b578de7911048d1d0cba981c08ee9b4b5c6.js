$(function () {
    var throughputDiv = $('#throughput-column');
    buildColumnChart(throughputDiv);

    var flowPressureDiv = $('#flowpressure-column');
    buildColumnChart(flowPressureDiv);

    var hoursDiv = $('#hours-column');
    buildColumnChart(hoursDiv);

    var cmdDiv = $('#cmd-column');
    buildColumnChart(cmdDiv);

    var statusReportThroughputDiv = $('#status-report-throughput-column');
    buildColumnChart(statusReportThroughputDiv);

    var statusReportDeliveredDiv = $('#status-report-delivered-column');
    buildColumnChart(statusReportDeliveredDiv);

    var statusReportDeadlineDiv = $('#status-report-deadline-bar');
    buildBarChart(statusReportDeadlineDiv);
});
