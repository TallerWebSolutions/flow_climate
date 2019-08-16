function buildLineChart(lineDiv) {
    new Highcharts.Chart({
        chart: {
            type: 'line',
            renderTo: lineDiv.attr('id')
        },
        title: {
            text: lineDiv.data('title'),
            x: -20
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            categories: lineDiv.data('xcategories'),
            title: { text: lineDiv.data('xtitle') }
        },
        yAxis: [{
            title: {
                text: lineDiv.data('ytitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }],
            stackLabels: {
                enabled: true
            },
            labels: {
                format: '{value:.2f}'
            }
        },
            {
                title: {
                    text: lineDiv.data('ytitleright')
                },
                labels: {
                    format: '{value:.2f}%'
                },
                opposite: true
            }
        ],
        tooltip: {
            enabled: true,
            valuePrefix: lineDiv.data('prefix'),
            valueSuffix: lineDiv.data('tooltipsuffix'),
            valueDecimals: lineDiv.data('decimals'),
            shared: true
        },
        legend: {
            layout: 'horizontal',
            align: 'center',
            verticalAlign: 'top',
            borderWidth: 0
        },
        plotOptions: {
            line: {
                dataLabels: {
                    enabled: true,
                    color: 'black',
                    formatter: function () {
                        return `${lineDiv.data('prefix') + Highcharts.numberFormat(this.y, lineDiv.data("decimals"), ",", ".")} ${lineDiv.data('tooltipsuffix')}`;
                    }
                }
            }
        },
        series: lineDiv.data('series')
    });
}
