function buildStrategicHighcharts() {
    const projectsCountDiv = $('#projects-count-column');
    buildColumnLineChart(projectsCountDiv);

    const flowPressureDiv = $('#flowpressure-per-month-line');
    buildLineChart(flowPressureDiv);

    const hoursPerMonth = $('#hours-per-month-line');
    buildLineChart(hoursPerMonth);

    const moneyPerMonth = $('#money-per-month-line');
    buildLineChart(moneyPerMonth);
}
;
