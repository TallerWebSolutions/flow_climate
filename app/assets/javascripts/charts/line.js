function buildLineChart(lineDiv) {
    $(function () {
        new Highcharts.Chart({
            chart: {
                renderTo: lineDiv.attr('id')
            },
            title: {
                text: lineDiv.data('title'),
                x: -20 //center
            },
            subtitle: {
                text: 'Source: Flow Climate'
            },
            xAxis: {
                categories: lineDiv.data('weeks'),
                title: {text: lineDiv.data('xtitle')}
            },
            yAxis: {
                title: {
                    text: lineDiv.data('ytitle')
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }]
            },
            tooltip: {
                formatter: function() {
                    return '<b>'+ this.series.name +'</b><br/>'+
                        'R$ '+ this.y.toFixed(2).replace(".",",");

                }
            },
            legend: {
                layout: 'vertical',
                align: 'right',
                verticalAlign: 'middle',
                borderWidth: 0
            },
            series: lineDiv.data('series')
        });
    })
}
