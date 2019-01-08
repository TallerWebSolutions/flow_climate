function buildColumnLineChart(columnDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: columnDiv.attr('id')
        },
        title: {
            text: columnDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: { // don't display the dummy year
                month: '%e. %b',
                year: '%b'
            },
            categories: columnDiv.data('xcategories'),
            title: {text: columnDiv.data('xtitle')}
        },
        yAxis: [{
            title: {
                text: columnDiv.data('ylinetitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }],
            stackLabels: {
                enabled: true
            },
            opposite: true
        }, {
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
        }],
        tooltip: {
            enabled: false
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
                    color: 'black',
                    formatter: function () {
                        return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), '.');
                    }
                }
            },
            spline: {
                dataLabels: {
                    enabled: true,
                    color: 'black',
                    formatter: function () {
                        return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), '.');
                    }
                }
            }
        },
        series: columnDiv.data('series')
    });
}
