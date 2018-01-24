$(function () {
    var lineDiv = $('#line');

    new Highcharts.Chart({
        chart: { renderTo: 'lineDiv' },
        title: {
            text: lineDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Control'
        },
        xAxis: {
            categories: lineDiv.data('weeks'),
            title: { text: lineDiv.data('xtitle') }
        },
        yAxis: {
            title: {
                text: lineDiv.data('ytitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        tooltip: {
            valueSuffix: ' ' + lineDiv.data('ytitle')
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        series: lineDiv.data('series')
    });
});
