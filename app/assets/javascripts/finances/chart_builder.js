function buildFinancesHighcharts() {
    const balanceDiv = $('#finances-balance-div');
    if (balanceDiv.length !== 0) {
        buildColumnLineChart(balanceDiv);
    }

    const costPerHourDiv = $('#finances-income-outcome-per-hour-div');
    if (costPerHourDiv.length !== 0) {
        buildLineChart(costPerHourDiv);
    }

    const stdDevIncomeOutcomeDiv = $('#finances-std-dev-income-outcome-div');
    if (stdDevIncomeOutcomeDiv.length !== 0) {
        buildLineChart(stdDevIncomeOutcomeDiv);
    }

    const meanCostPerHourDiv = $('#finances-mean-cost-per-hour-div');
    if (meanCostPerHourDiv.length !== 0) {
        buildLineChart(meanCostPerHourDiv);
    }
}
