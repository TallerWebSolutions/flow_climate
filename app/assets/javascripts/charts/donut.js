function buildDonutChart(donutDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: donutDiv.attr('id'),
            type: 'pie',
            height: donutDiv.data('chart_height')
        },
        title: {
            text: donutDiv.data('title')
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        yAxis: {
            title: {
                text: donutDiv.data('ytitle')
            }
        },
        plotOptions: {
            pie: {
                center: ['50%', '50%'],
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    }
                }
            }
        },
        series: [{
            name: donutDiv.data('seriesname'),
            colorByPoint: true,
            data: donutDiv.data('series'),
            size: '80%',
            innerSize: '40%'
        }]
    })
}