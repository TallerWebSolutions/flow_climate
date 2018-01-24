$(function () {
    var columnDiv = $('#column');

    new Highcharts.Chart({
        chart: {
            renderTo: 'column',
            type: 'column'
        },
        title: {
            text: columnDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Control'
        },
        xAxis: {
            categories: columnDiv.data('weeks'),
            title: { text: columnDiv.data('xtitle') }
        },
        yAxis: {
            title: {
                text: columnDiv.data('ytitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }],
            stackLabels: {
                enabled: true
            }
        },
        tooltip: {
            valueSuffix: ' ' + columnDiv.data('ytitle')
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        plotOptions: {
            column: {
                dataLabels: {
                    enabled: true,
                    color: 'black'
                }
            }
        },
        series: columnDiv.data('series')
    });
});
