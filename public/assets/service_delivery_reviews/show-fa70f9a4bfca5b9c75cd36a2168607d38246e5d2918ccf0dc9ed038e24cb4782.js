bindBlockFormModalAction();

let donutServiceDeliveryReviewClassesOfServiceDiv = $('#service-delivery-review-class-of-services-donut');
if (donutServiceDeliveryReviewClassesOfServiceDiv.length !== 0) {
    buildDonutChart(donutServiceDeliveryReviewClassesOfServiceDiv);
}

let donutServiceDeliveryReviewDelayedExpeditesDiv = $('#service-delivery-review-delayed-expedites-donut');
if (donutServiceDeliveryReviewDelayedExpeditesDiv.length !== 0) {
    buildDonutChart(donutServiceDeliveryReviewDelayedExpeditesDiv);
}

let donutServiceDeliveryReviewBugsDiv = $('#service-delivery-review-bugs-donut');
if (donutServiceDeliveryReviewBugsDiv.length !== 0) {
    buildSpeedometerChart(donutServiceDeliveryReviewBugsDiv);
}

let columnServiceDeliveryReviewLeadTimeBreakdownDiv = $('#service-delivery-review-lead-time-breakdown-column');
if (columnServiceDeliveryReviewLeadTimeBreakdownDiv.length !== 0) {
    buildColumnChart(columnServiceDeliveryReviewLeadTimeBreakdownDiv);
}

let donutServiceDeliveryReviewPortfolioUnitsDiv = $('#service-delivery-review-portfolio-units-donut');
if (donutServiceDeliveryReviewPortfolioUnitsDiv.length !== 0) {
    buildDonutChart(donutServiceDeliveryReviewPortfolioUnitsDiv);
}

let columnServiceDeliveryReviewFlowDataDiv = $('#service-delivery-review-flow-data-column');
if (columnServiceDeliveryReviewFlowDataDiv.length !== 0) {
    buildColumnChart(columnServiceDeliveryReviewFlowDataDiv);
}

const leadtimeControlChart = $('#service-delivery-review-leadtime-control-chart');
if (leadtimeControlChart.length !== 0) {
    buildTwoThresholdsChart(leadtimeControlChart);
}

$('#general-info-tab').addClass('active');
$('#sdr-general-info').show();
