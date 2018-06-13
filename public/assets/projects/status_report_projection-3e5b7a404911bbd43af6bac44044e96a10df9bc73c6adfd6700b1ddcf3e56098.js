$(function () {
    var statusReportDatesOddsDiv = $('#status-report-dates-odds-column');
    buildColumnChart(statusReportDatesOddsDiv);

    var statusReportMonteCarloDiv = $('#status-report-montecarlo-column');
    buildColumnChart(statusReportMonteCarloDiv);
});
