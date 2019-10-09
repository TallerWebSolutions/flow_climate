$(function () {
    const donutDiv = $('#risk-alert-color-backlog');
    if (donutDiv.length !== 0) {
        buildDonutChart(donutDiv);
    }

});
$(function () {
    const donutDiv = $('#risk-alert-color-flowpressure');
    if (donutDiv.length !== 0) {
        buildDonutChart(donutDiv);
    }

});
$(function () {
    const donutDiv = $('#risk-alert-color-profit');
    if (donutDiv.length !== 0) {
        buildDonutChart(donutDiv);
    }
});

$(function () {
    const donutDiv = $('#risk-alert-color-hours');
    if (donutDiv.length !== 0) {
        buildDonutChart(donutDiv);
    }
});

$(function () {
    const donutDiv = $('#risk-alert-color-money');
    if (donutDiv.length !== 0) {
        buildDonutChart(donutDiv);
    }
});
