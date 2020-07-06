function buildContractCharts() {
    const donutScopeCompleted = $("#contracts-dashboard-scope-completed-donut");
    if (donutScopeCompleted.length !== 0) {
        buildDonutChart(donutScopeCompleted);
    }

    const donutHoursCompleted = $("#contracts-dashboard-hours-completed-donut");
    if (donutHoursCompleted.length !== 0) {
        buildDonutChart(donutHoursCompleted);
    }

    const lineLeadtimeCustomerAccumulated = $("#line-leadtime-accumalated-customer");
    if (lineLeadtimeCustomerAccumulated.length !== 0) {
        buildLineChart(lineLeadtimeCustomerAccumulated);
    }

    const lineCustomerBurnupFinancial = $("#customer-financial-burnup-line");
    if (lineCustomerBurnupFinancial.length !== 0) {
        buildLineChart(lineCustomerBurnupFinancial);
    }

    const lineCustomerBurnupHours = $("#customer-hours-burnup-line");
    if (lineCustomerBurnupHours.length !== 0) {
        buildLineChart(lineCustomerBurnupHours);
    }

    const lineCustomerBurnupScope = $("#customer-scope-burnup-line");
    if (lineCustomerBurnupScope.length !== 0) {
        buildLineChart(lineCustomerBurnupScope);
    }

    const customerQualityPerPeriod = $("#customer-quality-line");
    if (customerQualityPerPeriod.length !== 0) {
        buildLineChart(customerQualityPerPeriod);
    }

    const customerHoursConsumed = $("#customer-hours-consumed-column-line");
    if (customerHoursConsumed.length !== 0) {
        buildColumnLineChart(customerHoursConsumed);
    }

    const customerThroughputPerPeriod = $("#customer-throughput-column-dashboard");
    if (customerThroughputPerPeriod.length !== 0) {
        buildColumnChart(customerThroughputPerPeriod);
    }
}