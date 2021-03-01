function buildColumnLineChart(columnDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: columnDiv.attr('id')
        },
        title: {
            text: columnDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            categories: columnDiv.data('xcategories'),
            title: { text: columnDiv.data('xtitle') }
        },
        yAxis: [{
            title: {
                text: columnDiv.data('ylinetitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }],
            stackLabels: {
                enabled: true
            },
            opposite: true
        }, {
            title: {
                text: columnDiv.data('ytitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }],
            stackLabels: {
                enabled: true
            }
        }],
        tooltip: {
            enabled: true,
            formatter: function () {
                return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), ',', '.');
            }
        },
        legend: {
            type: 'line',
            align: 'center',
            verticalAlign: 'top',
            x: 0,
            y: 0
        },
        plotOptions: {
            column: {
                dataLabels: {
                    enabled: true,
                    color: 'black',
                    formatter: function () {
                        return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), ',', '.');
                    }
                }
            },
            spline: {
                dataLabels: {
                    enabled: true,
                    formatter: function () {
                        let firstPoint = this.series.data[0];
                        let lastPoint = this.series.data[this.series.data.length - 1];

                        if ((this.point.category === firstPoint.category && this.point.y === firstPoint.y) || (this.point.category === lastPoint.category  && this.point.y === lastPoint.y)) {
                            return `<span style='color: ${this.color}'>${columnDiv.data('prefix') + Highcharts.numberFormat(this.y, columnDiv.data("decimals"), ",", ".") + " " + columnDiv.data('datalabelsuffix')}</span>`;
                        }
                    }
                }
            }
        },
        series: columnDiv.data('series')
    });
};
