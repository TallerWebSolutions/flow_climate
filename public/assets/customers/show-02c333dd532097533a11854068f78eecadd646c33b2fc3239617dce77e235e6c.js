const lineLeadtimeCustomerAccumulated = $("#line-leadtime-accumalated-customer");
if (lineLeadtimeCustomerAccumulated.length !== 0) {
    buildLineChart(lineLeadtimeCustomerAccumulated);
}

const customerHoursConsumed = $("#customer-hours-consumed-line");
if (customerHoursConsumed.length !== 0) {
    buildLineChart(customerHoursConsumed);
}

const customerThroughputPerPeriod = $("#customer-throughput-column-dashboard");
if (customerThroughputPerPeriod.length !== 0) {
    buildColumnChart(customerThroughputPerPeriod);
};
