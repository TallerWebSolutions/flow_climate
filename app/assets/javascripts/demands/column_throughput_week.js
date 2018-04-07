$(function () {
    var columnDiv = $('#last-week-throughput-column');
    buildColumnChart(columnDiv);

    var wipDiv = $('#wip-per-day');
    buildColumnChart(wipDiv);
});
