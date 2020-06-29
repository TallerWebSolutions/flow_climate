function buildWordCloudChart(wordCloudDiv) {
    new Highcharts.Chart({
        chart: {
            renderTo: wordCloudDiv.attr('id'),
            type: 'area',
            zoomType: 'x'
        },
        title: {
            text: wordCloudDiv.data('title'),
            x: -20 //center
        },
        series: [{
            type: 'wordcloud',
            data: wordCloudDiv.data('series'),
            name: 'Occurrences'
        }]
    });
};
