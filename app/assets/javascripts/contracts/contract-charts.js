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

    const contractThroughputPerPeriod = $("#contract-throughput-column-dashboard");
    if (contractThroughputPerPeriod.length !== 0) {
        buildColumnLineChart(contractThroughputPerPeriod);
    }

    const contractOperationalRiskValues = $("#line-operational-risk-contract");
    if (contractOperationalRiskValues.length !== 0) {
        buildLineChart(contractOperationalRiskValues);
    }

    const hoursBlockedPerDeliveryValues = $("#line-hours-blocked-per-delivery-contract");
    if (hoursBlockedPerDeliveryValues.length !== 0) {
        buildLineChart(hoursBlockedPerDeliveryValues);
    }

    const externalDependecyValues = $("#line-external-dependency-contract");
    if (externalDependecyValues.length !== 0) {
        buildLineChart(externalDependecyValues);
    }

    const effortHoursInfoValues = $("#contract-hours-consumed-column-line");
    if (effortHoursInfoValues.length !== 0) {
        buildColumnLineChart(effortHoursInfoValues);
    }
}