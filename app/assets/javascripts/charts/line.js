function buildLineChart(columnDiv) {
    new Highcharts.Chart({
        chart: {
            type: 'line',
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
            line: {
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
