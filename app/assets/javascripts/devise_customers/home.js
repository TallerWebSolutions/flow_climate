//= require 'charts/column-line'
//= require 'charts/line'

const customerHoursConsumed = $("#devise-customer-consumed-hours");
if (customerHoursConsumed.length !== 0) {
  buildColumnLineChart(customerHoursConsumed);
}

const customerCostPerDemand = $("#customer-cost-per-demand-dashboard");
if (customerCostPerDemand.length !== 0) {
  buildLineChart(customerCostPerDemand);
}

const customerThroughput = $("#customer-throughput-dashboard");
if (customerThroughput.length !== 0) {
  buildLineChart(customerThroughput);
}

const customerBugs = $("#customer-bugs");
if (customerBugs.length !== 0) {
  buildLineChart(customerBugs)
}
