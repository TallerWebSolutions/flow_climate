function buildStrategicHighcharts() {
    var projectsCountDiv = $('#projects-count-column');
    buildColumnLineChart(projectsCountDiv);

    var flowPressureDiv = $('#flowpressure-per-month-line');
    buildLineChart(flowPressureDiv);

    var hoursPerMonth = $('#hours-per-month-line');
    buildLineChart(hoursPerMonth);

    var moneyPerMonth = $('#money-per-month-line');
    buildLineChart(moneyPerMonth);
}
