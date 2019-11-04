function buildHistogramChart(histogramDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: histogramDiv.attr('id')
        },
        title: {
            text: histogramDiv.data('title')
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: [{
            title: { text: 'Data' },
            alignTicks: false
        }, {
            title: { text: 'Histogram' },
            alignTicks: false,
            opposite: true
        }],

        yAxis: [{
            title: { text: 'Data' }
        }, {
            title: { text: 'Histogram' },
            opposite: true
        }],
        tooltip: {
            valueDecimals: histogramDiv.data('decimals')
        },
        plotOptions: {
            histogram: {
                tooltip: {
                    pointFormat:  `<span style="font-size:10px">{point.x:.2f} - {point.x2:.2f}
                    </span><br/>
                    <span style="color:{point.color}">\u25CF</span>
                    {series.name} <b>{point.y}</b><br/>`
                }
            }
        },
        series: histogramDiv.data('series')
    });
}
