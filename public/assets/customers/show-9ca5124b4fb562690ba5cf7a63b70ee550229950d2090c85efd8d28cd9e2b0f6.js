const lineLeadtimeCustomerAccumulated = $("#line-leadtime-accumalated-customer");
if (lineLeadtimeCustomerAccumulated.length !== 0) {
    buildLineChart(lineLeadtimeCustomerAccumulated);
}

const customerHoursConsumed = $("#customer-hours-consumed-column-line");
if (customerHoursConsumed.length !== 0) {
    buildColumnLineChart(customerHoursConsumed);
}

const customerThroughputPerPeriod = $("#customer-throughput-column-dashboard");
if (customerThroughputPerPeriod.length !== 0) {
    buildColumnChart(customerThroughputPerPeriod);
};
