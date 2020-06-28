function buildScatterChart(scatterDiv) {
    new Highcharts.Chart({
        chart: {
            type: 'scatter',
            zoomType: 'xy',
            renderTo: scatterDiv.attr('id')
        },
        title: {
            text: scatterDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            categories: scatterDiv.data('xcategories'),
            title: { text: scatterDiv.data('xtitle') }
        },
        yAxis: {
            title: {
                text: scatterDiv.data('tooltipsuffix')
            },
            plotLines: [{
                value: scatterDiv.data('percentile95'),
                color: 'green',
                dashStyle: 'shortdash',
                width: 2,
                label: {
                    style: {
                        color: 'green'
                    },
                    text: `percentile 95% (${parseFloat(scatterDiv.data('percentile95')).toFixed(2)} ${scatterDiv.data('tooltipsuffix')})`
                }
            },{
                value: scatterDiv.data('percentile80'),
                color: '#DAA520',
                dashStyle: 'shortdash',
                width: 2,
                label: {
                    style: {
                        color: '#DAA520'
                    },
                    text: `percentile 80% (${parseFloat(scatterDiv.data('percentile80')).toFixed(2)} ${scatterDiv.data('tooltipsuffix')})`
                }
            },{
                value: scatterDiv.data('percentile60'),
                color: 'red',
                dashStyle: 'shortdash',
                width: 2,
                label: {
                    style: {
                        color: 'red'
                    },
                    text: `percentile 60% (${parseFloat(scatterDiv.data('percentile60')).toFixed(2)} ${scatterDiv.data('tooltipsuffix')})`
                }
            }]
        },
        tooltip: {
            formatter:function(){
                return `${this.key}: ${this.y.toFixed(2)} ${scatterDiv.data('tooltipsuffix')}`;
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        plotOptions: {
            scatter: {
                marker: {
                    radius: 2,
                    states: {
                        hover: {
                            enabled: true,
                            lineColor: 'rgb(100,100,100)'
                        }
                    }
                },
                states: {
                    hover: {
                        marker: {
                            enabled: false
                        }
                    }
                },
                tooltip: {
                    headerFormat: '<b>{series.name}</b><br>',
                    pointFormat: `{point.name}: {point.y:.2f} ${scatterDiv.data('tooltipsuffix')}`
                }
            }
        },
        series: scatterDiv.data('series')
    });
};
