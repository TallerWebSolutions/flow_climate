let donutServiceDeliveryReviewClassesOfServiceDiv = $('#service-delivery-review-class-of-services-donut');
buildDonutChart(donutServiceDeliveryReviewClassesOfServiceDiv);

let donutServiceDeliveryReviewDelayedExpeditesDiv = $('#service-delivery-review-delayed-expedites-donut');
buildDonutChart(donutServiceDeliveryReviewDelayedExpeditesDiv);

let donutServiceDeliveryReviewBugsDiv = $('#service-delivery-review-bugs-donut');
buildSpeedometerChart(donutServiceDeliveryReviewBugsDiv);

let columnServiceDeliveryReviewLeadTimeBreakdownDiv = $('#service-delivery-review-lead-time-breakdown-column');
buildColumnChart(columnServiceDeliveryReviewLeadTimeBreakdownDiv);

let donutServiceDeliveryReviewPortfolioUnitsDiv = $('#service-delivery-review-portfolio-units-donut');
buildDonutChart(donutServiceDeliveryReviewPortfolioUnitsDiv);

let donutServiceDeliveryReviewFlowDataDiv = $('#service-delivery-review-flow-data-column');
buildColumnChart(donutServiceDeliveryReviewFlowDataDiv);

const leadtimeControlChart = $('#service-delivery-review-leadtime-control-chart');
buildTwoThresholdsChart(leadtimeControlChart);
