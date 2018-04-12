function buildDonutChart(donutDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: donutDiv.attr('id'),
            type: 'pie'
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
                    enabled: false
                }
            }
        },
        series: [{
            name: donutDiv.data('seriesname'),
            data: donutDiv.data('series'),
            size: '100%',
            innerSize: '40%'
        }]
    })
}
;
