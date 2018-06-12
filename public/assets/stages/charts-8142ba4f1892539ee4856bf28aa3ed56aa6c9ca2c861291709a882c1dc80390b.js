function buildStageHighcharts() {
    var entrancesPerWeekday = $('#entrances-per-weekday-column');
    buildColumnChart(entrancesPerWeekday);

    var entrancesPerDay = $('#entrances-per-day-column');
    buildColumnChart(entrancesPerDay);

    var entrancesPerHour = $('#entrances-per-hour-column');
    buildColumnChart(entrancesPerHour);

    var outPerWeekday = $('#out-per-weekday-column');
    buildColumnChart(outPerWeekday);

    var outPerDay = $('#out-per-day-column');
    buildColumnChart(outPerDay);

    var outPerHour = $('#out-per-hour-column');
    buildColumnChart(outPerHour);

    var lineAvgHoursInStage = $('#line-avg-hours-in-stage');
    buildLineChart(lineAvgHoursInStage);
}
;
