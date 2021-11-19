bindBlockFormModalAction();

let donutRiskReviewClassesOfServiceDiv = $("#risk-review-class-of-services-donut");
if (donutRiskReviewClassesOfServiceDiv.length !== 0) {
    buildDonutChart(donutRiskReviewClassesOfServiceDiv);
}

let donutRiskReviewBlockDiv = $("#risk-review-block-categories-donut");
if (donutRiskReviewBlockDiv.length !== 0) {
    buildDonutChart(donutRiskReviewBlockDiv);
}

let donutRiskReviewEventDiv = $("#risk-review-event-categories-donut");
if (donutRiskReviewEventDiv.length !== 0) {
    buildDonutChart(donutRiskReviewEventDiv);
}

let lineAverageBlockedTimeInTime = $("#average-blocked-time-in-time");
if (lineAverageBlockedTimeInTime.length !== 0) {
    buildLineChart(lineAverageBlockedTimeInTime);
}
