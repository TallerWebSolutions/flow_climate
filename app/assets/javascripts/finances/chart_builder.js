function buildFinancesHighcharts() {
    const balanceDiv = $('#finances-balance-div');
    buildColumnLineChart(balanceDiv);

    const costPerHourDiv = $('#finances-income-outcome-per-hour-div');
    buildLineChart(costPerHourDiv);

    const stdDevIncomeOutcomeDiv = $('#finances-std-dev-income-outcome-div');
    buildLineChart(stdDevIncomeOutcomeDiv);

    const meanCostPerHourDiv = $('#finances-mean-cost-per-hour-div');
    buildLineChart(meanCostPerHourDiv);
}
