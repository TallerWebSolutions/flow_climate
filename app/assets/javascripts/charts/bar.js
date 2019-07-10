function buildBarChart(barDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: barDiv.attr('id'),
            type: 'bar',
            zoomType: 'x',
            height: barDiv.data('chart-height')
        },
        title: {
            text: barDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            categories: barDiv.data('xcategories'),
            title: {text: barDiv.data('xtitle')}
        },
        yAxis: {
            title: {
                text: barDiv.data('ytitle')
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
        legend: {
            enabled: barDiv.data('legend-enabled'),
            type: 'line',
            align: 'center',
            verticalAlign: 'top',
            x: 0,
            y: 0
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true
                }
            },
            series: {
                stacking: barDiv.data('stacking')
            }
        },
        tooltip: {
            formatter: function () {
                return `${Highcharts.numberFormat(this.y, barDiv.data('decimals'), '.')} ${barDiv.data('tooltipsufix')}`;
            }
        },
        series: barDiv.data('series')
    });
}
