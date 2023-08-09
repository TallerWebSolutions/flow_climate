function buildLineChart(lineDiv) {
    new Highcharts.Chart({
        chart: {
            type: 'line',
            renderTo: lineDiv.attr('id')
        },
        title: {
            text: lineDiv.data('title'),
            x: -20
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            categories: lineDiv.data('xcategories'),
            title: { text: lineDiv.data('xtitle') }
        },
        yAxis: [{
            title: {
                text: lineDiv.data('ytitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }],
            stackLabels: {
                enabled: true
            },
            labels: {
            },
            softMax: 100,
        },
            {
                title: {
                    text: lineDiv.data('ytitleright')
                },
                labels: {
                    format: 'value:..${lineDiv.data(\'decimals\')}f'
                },
                opposite: true
            }
        ],
        tooltip: {
            enabled: true,
            valuePrefix: lineDiv.data('prefix'),
            valueSuffix: ` ${lineDiv.data('tooltipsuffix')}`,
            valueDecimals: lineDiv.data('decimals'),
            shared: true
        },
        legend: {
            layout: 'horizontal',
            align: 'center',
            verticalAlign: 'top',
            borderWidth: 0
        },
        plotOptions: {
            line: {
                dataLabels: {
                    enabled: true,
                    formatter: function () {
                        let firstPoint = this.series.data[0];
                        let lastPoint = this.series.data[this.series.data.length - 1];

                        if ((this.point.category === firstPoint.category && this.point.y === firstPoint.y) || (this.point.category === lastPoint.category  && this.point.y === lastPoint.y)) {
                            if (lineDiv.data('prefix')) {
                                return `<span style='color: ${this.color}'>${lineDiv.data('prefix') + " " + Highcharts.numberFormat(this.y, lineDiv.data("decimals"), ",", ".") + " " + lineDiv.data('datalabelsuffix')}</span>`;
                            } else {
                                return `<span style='color: ${this.color}'>${Highcharts.numberFormat(this.y, lineDiv.data("decimals"), ",", ".") + " " + lineDiv.data('datalabelsuffix')}</span>`;
                            }
                        }
                    }
                }
            }
        },
        series: lineDiv.data('series')
    });
};
