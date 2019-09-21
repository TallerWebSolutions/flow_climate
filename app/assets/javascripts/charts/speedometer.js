function buildSpeedometerChart(chartDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: chartDiv.attr('id'),
            type: 'gauge',
            plotBackgroundColor: null,
            plotBackgroundImage: null,
            plotBorderWidth: 0,
            plotShadow: false
        },
        title: {
            text: chartDiv.data('title'),
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },

        pane: {
            startAngle: -150,
            endAngle: 150,
            background: [{
                backgroundColor: {
                    linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                    stops: [
                        [0, '#FFF'],
                        [1, '#333']
                    ]
                },
                borderWidth: 0,
                outerRadius: '109%'
            }, {
                backgroundColor: {
                    linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                    stops: [
                        [0, '#333'],
                        [1, '#FFF']
                    ]
                },
                borderWidth: 1,
                outerRadius: '107%'
            }, {
                // default background
            }, {
                backgroundColor: '#DDD',
                borderWidth: 0,
                outerRadius: '105%',
                innerRadius: '103%'
            }]
        },

        // the value axis
        yAxis: {
            min: 0,
            max: 100,

            minorTickInterval: 'auto',
            minorTickWidth: 1,
            minorTickLength: 10,
            minorTickPosition: 'inside',
            minorTickColor: '#666',

            tickPixelInterval: 30,
            tickWidth: 2,
            tickPosition: 'inside',
            tickLength: 10,
            tickColor: '#666',
            labels: {
                step: 2,
                rotation: 'auto'
            },
            title: {
                text: chartDiv.data('qualitytitle')
            },
            plotBands: [{
                from: 0,
                to: chartDiv.data('bottomquality'),
                color: '#DDDF0D' // yellow
            }, {
                from: chartDiv.data('bottomquality'),
                to: chartDiv.data('topquality'),
                color: '#55BF3B' // green
            }, {
                from: chartDiv.data('topquality'),
                to: 100,
                color: '#DF5353' // red
            }]
        },plotOptions: {
            gauge: {
                dataLabels: {
                    enabled: true,
                    formatter: function() {
                        return `${this.y.toFixed(2)} %`;
                    }
                }
            }
        },
        series: chartDiv.data('series')
    });
}
