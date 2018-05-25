function buildFlowDemandsCharts() {
    var processingRateDiv = $('#processing-rate-column');
    buildColumnChart(processingRateDiv);

    var wipDiv = $('#wip-per-day-column');
    buildColumnChart(wipDiv);

    var hoursPerMonthDiv = $('#hours-per-month-column');
    buildColumnChart(hoursPerMonthDiv);
}
