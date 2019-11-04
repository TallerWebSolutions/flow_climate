function buildColumnChart(columnDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: columnDiv.attr('id'),
            type: 'column',
            zoomType: 'x'
        },
        title: {
            text: columnDiv.data('title'),
            x: -20 //center
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },
        xAxis: {
            type: 'datetime',
            categories: columnDiv.data("xcategories"),
            title: { text: columnDiv.data("xtitle") }
        },
        yAxis: {
            title: {
                text: columnDiv.data('ytitle')
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }],
            stackLabels: {
                enabled: columnDiv.data('stacking') === "normal",
                formatter: function() {
                    return Highcharts.numberFormat(this.total, columnDiv.data('decimals'), ',');
                }
            }
        },
        tooltip: {
            formatter:function(){
                return `<b>${this.series.name}</b><br>${this.key}: ${this.y.toFixed(2)} ${columnDiv.data('tooltipsuffix')}`;
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
                stacking: columnDiv.data('stacking'),
                dataLabels: {
                    enabled: columnDiv.data('stacking') !== "normal",
                    formatter: function() {
                        return Highcharts.numberFormat(this.y, columnDiv.data('decimals'), ',');
                    }
                }
            }
        },
        responsive: {
            rules: [{
                condition: {
                    maxWidth: 1000
                },
                chartOptions: {
                    xAxis: {
                        labels: {
                            step: 1
                        }
                    }
                }
            }, {
                condition: {
                    maxWidth: 600
                },
                chartOptions: {
                    xAxis: {
                        labels: {
                            step: 3,
                            style: {
                                fontSize: "0.7em"
                            }
                        }
                    }
                }
            }, {
                condition: {
                    maxWidth: 350
                },
                chartOptions: {
                    xAxis: {
                        labels: {
                            step: 5
                        }
                    }
                }
            }, {
                condition: {
                    maxWidth: 200
                },
                chartOptions: {
                    xAxis: {
                        labels: {
                            step: 8
                        }
                    }
                }
            }, {
                condition: {
                    maxWidth: 150
                },
                chartOptions: {
                    xAxis: {
                        labels: {
                            formatter: function() {
                                return '';
                            }
                        }
                    }
                }
            }]
        },
        series: columnDiv.data('series')
    });
}
