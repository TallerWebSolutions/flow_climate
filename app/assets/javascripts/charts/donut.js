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
        tooltip: {
            valueSuffix: ` ${donutDiv.data("tooltipsuffix")}`
        },
        plotOptions: {
            pie: {
                center: ['50%', '50%'],
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    formatter: function() {
                        return `${Math.round(this.percentage * 100) / 100} %`;
                    }
                },
                showInLegend: true
            }
        },
        series: [{
            name: donutDiv.data('seriesname'),
            colorByPoint: true,
            data: donutDiv.data('series'),
            size: '80%',
            innerSize: '20%'
        }]
    })
}