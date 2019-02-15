function buildFinancesHighcharts() {
    const balanceDiv = $('#finances-balance-div');
    if (balanceDiv) {
        buildColumnLineChart(balanceDiv);
    }

    const costPerHourDiv = $('#finances-income-outcome-per-hour-div');
    if (costPerHourDiv) {
        buildLineChart(costPerHourDiv);
    }

    const stdDevIncomeOutcomeDiv = $('#finances-std-dev-income-outcome-div');
    if (stdDevIncomeOutcomeDiv) {
        buildLineChart(stdDevIncomeOutcomeDiv);
    }

    const meanCostPerHourDiv = $('#finances-mean-cost-per-hour-div');
    if (meanCostPerHourDiv) {
        buildLineChart(meanCostPerHourDiv);
    }
}
;
