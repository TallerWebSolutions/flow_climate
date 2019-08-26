function buildAreaChart(areaDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: areaDiv.attr('id'),
            type: 'area',
            zoomType: 'x'
        },
        title: {
            text: areaDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            categories: areaDiv.data('xcategories'),
            title: { text: areaDiv.data('xtitle') }
        },
        yAxis: {
            title: {
                text: areaDiv.data('ytitle')
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
            type: 'line',
            align: 'center',
            verticalAlign: 'bottom',
            x: 0,
            y: 0
        },
        plotOptions: {
            area: {
                marker: {
                    enabled: false,
                    symbol: 'circle',
                    radius: 2,
                    states: {
                        hover: {
                            enabled: true
                        }
                    }
                }
            }
        },
        series: areaDiv.data('series')
    });
}
;
