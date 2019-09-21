function buildTwoThresholdsChart(chartDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: chartDiv.attr('id'),
            zoomType: 'x'
        },
        title: {
            text: chartDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            categories: chartDiv.data('xcategories'),
            title: {text: chartDiv.data('xtitle')}
        },
        yAxis: [{
            title: {
                text: chartDiv.data('ylinetitle')
            },
            stackLabels: {
                enabled: true
            },
            opposite: true
        }, {
            title: {
                text: chartDiv.data('ytitle')
            },
            plotLines: [{
                value: chartDiv.data('bottomthreshold'),
                color: 'green',
                dashStyle: 'shortdash',
                width: 2,
                label: {
                    text: chartDiv.data('bottomthresholdtext')
                }
            }, {
                value: chartDiv.data('topthreshold'),
                color: 'red',
                dashStyle: 'shortdash',
                width: 2,
                label: {
                    text: chartDiv.data('topthresholdtext')
                }
            }],
            stackLabels: {
                enabled: true
            }
        }],
        tooltip: {
            enabled: true,
            valuePrefix: chartDiv.data('prefix'),
            valueSuffix: ` ${chartDiv.data('tooltipsuffix')}`,
            valueDecimals: chartDiv.data('decimals'),
            shared: true,
            pointFormat: `{point.name}: {point.y}<br/>{point.end_date}`
        },
        legend: {
            type: 'line',
            align: 'center',
            verticalAlign: 'bottom',
            x: 0,
            y: 0
        },
        series: chartDiv.data('series')
    });
}
