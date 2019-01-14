$("#general-loader").hide();

const hoursGauge = $('#hours-gauge');
buildGaugeChart(hoursGauge);

accordionBehaviour();

statusReportPeriodBehaviour();
operationalChartsPeriodBehaviour();
searchWeekBehaviour();
