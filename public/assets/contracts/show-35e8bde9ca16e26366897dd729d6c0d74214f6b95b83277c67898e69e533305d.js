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
                enabled: true,
                formatter: function () {
                    return Highcharts.numberFormat(this.total, columnDiv.data('decimals'), ',', '.');
                }
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
                stacking: columnDiv.data('stacking'),
                dataLabels: {
                    enabled: columnDiv.data('stacking') !== "normal",
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
};
function buildContractCharts() {
    const donutScopeCompleted = $("#contracts-dashboard-scope-completed-donut");
    if (donutScopeCompleted.length !== 0) {
        buildDonutChart(donutScopeCompleted);
    }

    const donutHoursCompleted = $("#contracts-dashboard-hours-completed-donut");
    if (donutHoursCompleted.length !== 0) {
        buildDonutChart(donutHoursCompleted);
    }

    const lineLeadtimeCustomerAccumulated = $("#line-leadtime-accumalated-customer");
    if (lineLeadtimeCustomerAccumulated.length !== 0) {
        buildLineChart(lineLeadtimeCustomerAccumulated);
    }

    const lineCustomerBurnupFinancial = $("#customer-financial-burnup-line");
    if (lineCustomerBurnupFinancial.length !== 0) {
        buildLineChart(lineCustomerBurnupFinancial);
    }

    const lineCustomerBurnupHours = $("#customer-hours-burnup-line");
    if (lineCustomerBurnupHours.length !== 0) {
        buildLineChart(lineCustomerBurnupHours);
    }

    const lineCustomerBurnupScope = $("#customer-scope-burnup-line");
    if (lineCustomerBurnupScope.length !== 0) {
        buildLineChart(lineCustomerBurnupScope);
    }

    const customerQualityPerPeriod = $("#customer-quality-line");
    if (customerQualityPerPeriod.length !== 0) {
        buildLineChart(customerQualityPerPeriod);
    }

    const contractThroughputPerPeriod = $("#contract-throughput-column-dashboard");
    if (contractThroughputPerPeriod.length !== 0) {
        buildColumnLineChart(contractThroughputPerPeriod);
    }

    const contractOperationalRiskValues = $("#line-operational-risk-contract");
    if (contractOperationalRiskValues.length !== 0) {
        buildLineChart(contractOperationalRiskValues);
    }

    const hoursBlockedPerDeliveryValues = $("#line-hours-blocked-per-delivery-contract");
    if (hoursBlockedPerDeliveryValues.length !== 0) {
        buildLineChart(hoursBlockedPerDeliveryValues);
    }

    const externalDependecyValues = $("#line-external-dependency-contract");
    if (externalDependecyValues.length !== 0) {
        buildLineChart(externalDependecyValues);
    }

    const effortHoursInfoValues = $("#contract-hours-consumed-column-line");
    if (effortHoursInfoValues.length !== 0) {
        buildColumnLineChart(effortHoursInfoValues);
    }
};





buildContractCharts();
