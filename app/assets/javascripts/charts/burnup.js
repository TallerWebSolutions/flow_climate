function buildBurnupChart(burnupDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: burnupDiv.attr('id'),
            zoomType: 'x'
        },
        plotOptions: {
            series: {
                marker: {
                    enabled: true,
                    radius: 2
                }
            }
        },

        title: {
            text: burnupDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: { // don't display the dummy year
                month: '%e. %b',
                year: '%b'
            },
            categories: burnupDiv.data('weeks'),
            title: { text: burnupDiv.data('xtitle') }
        },
        yAxis: {
            title: {
                text: burnupDiv.data('ytitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        tooltip: {
            formatter: function () {
                return Highcharts.numberFormat(this.y, burnupDiv.data('decimals'), ',', '.');
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        series: [{
            name: 'Escopo',
            data: burnupDiv.data('scope')
        }, {
            name: 'Ideal',
            data: burnupDiv.data('ideal')
        }, {
            name: 'Atual',
            data: burnupDiv.data('current')
        }]
    });
}
