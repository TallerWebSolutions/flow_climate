$(function () {
    var burnupHours = $('#burnup-hours');
    buildBurnupChart(burnupHours);

    var statusReportThroughputDiv = $('#status-report-throughput-column');
    buildColumnChart(statusReportThroughputDiv);

    var statusReportDeliveredDiv = $('#status-report-delivered-column');
    buildColumnChart(statusReportDeliveredDiv);

    var statusReportDeadlineDiv = $('#status-report-deadline-bar');
    buildBarChart(statusReportDeadlineDiv);

    var statusReportDatesOddsDiv = $('#status-report-dates-odds-column');
    buildColumnChart(statusReportDatesOddsDiv);

    var statusReportMonteCarloDiv = $('#status-report-montecarlo-column');
    buildColumnChart(statusReportMonteCarloDiv);

    var statusReportHoursDiv = $('#status-report-hours-column');
    buildColumnChart(statusReportHoursDiv);
});
