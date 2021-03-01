const customerHoursConsumed = $("#customer-hours-consumed-column-line");
if (customerHoursConsumed.length !== 0) {
    buildColumnLineChart(customerHoursConsumed);
}

const customerAvgHoursConsumed = $("#customer-avg-hours-consumed-line");
if (customerAvgHoursConsumed.length !== 0) {
    buildLineChart(customerAvgHoursConsumed);
};
