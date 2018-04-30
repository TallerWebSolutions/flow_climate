function buildColumnChart(columnDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: columnDiv.attr('id'),
            type: 'column',
            zoomType: 'x'
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
            formatter: function () {
                if (!columnDiv.data('ysuffix')) {
                    return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), '.');
                } else {
                    return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), '.') + ' ' + columnDiv.data('ysuffix');
                }
            }
        },
        legend: {
            type: 'line',
            align: 'center',
            verticalAlign: 'bottom',
            x: 0,
            y: 0
        },
        plotOptions: {
            column: {
                dataLabels: {
                    enabled: true,
                    color: 'black',
                    formatter: function () {
                        if (!columnDiv.data('ysuffix')) {
                            return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), '.');
                        } else {
                            return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), '.') + ' ' + columnDiv.data('ysuffix');
                        }
                    }
                },
                stacking: columnDiv.data('stacking')
            }
        },
        series: columnDiv.data('series')
    });
}
;
