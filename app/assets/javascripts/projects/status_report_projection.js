function buildStatusReportProjectionCharts() {
    const statusReportDatesOddsDiv = $('#status-report-dates-odds-column');
    if (statusReportDatesOddsDiv.length) {
        buildColumnChart(statusReportDatesOddsDiv);
    }
}
