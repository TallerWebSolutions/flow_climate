$(function () {
    var columnDiv = $('#processing-rate-column');
    buildColumnChart(columnDiv);

    var wipDiv = $('#wip-per-day-column');
    buildColumnChart(wipDiv);
});
