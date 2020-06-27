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

const customerHoursConsumed = $("#customer-hours-consumed-column-line");
if (customerHoursConsumed.length !== 0) {
    buildColumnLineChart(customerHoursConsumed);
}

const customerThroughputPerPeriod = $("#customer-throughput-column-dashboard");
if (customerThroughputPerPeriod.length !== 0) {
    buildColumnChart(customerThroughputPerPeriod);
}
