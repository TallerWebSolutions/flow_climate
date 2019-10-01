let donutRiskReviewClassesOfServiceDiv = $('#risk-review-class-of-services-donut');
if (donutRiskReviewClassesOfServiceDiv.length !== 0) {
    buildDonutChart(donutRiskReviewClassesOfServiceDiv);
}

let donutRiskReviewBlockDiv = $('#risk-review-block-categories-donut');
if (donutRiskReviewBlockDiv.length !== 0) {
    buildDonutChart(donutRiskReviewBlockDiv);
}

let donutRiskReviewImpactDiv = $('#risk-review-impact-categories-donut');
if (donutRiskReviewImpactDiv.length !== 0) {
    buildDonutChart(donutRiskReviewImpactDiv);
}
