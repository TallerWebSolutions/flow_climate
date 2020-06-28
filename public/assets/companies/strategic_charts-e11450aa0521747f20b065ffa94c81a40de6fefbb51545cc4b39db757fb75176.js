function buildStrategicHighcharts() {
    const projectsCountDiv = $('#projects-count-column');
    if (projectsCountDiv) {
        buildColumnLineChart(projectsCountDiv);
    }

    const flowPressureDiv = $('#flowpressure-per-month-line');
    if (flowPressureDiv) {
        buildLineChart(flowPressureDiv);
    }

    const hoursPerMonth = $('#hours-per-month-line');
    if (hoursPerMonth) {
        buildLineChart(hoursPerMonth);
    }

    const moneyPerMonth = $('#money-per-month-line');
    if (moneyPerMonth) {
        buildLineChart(moneyPerMonth);
    }
};
