function buildGanttChart(ganttDiv) {
    Highcharts.ganttChart(ganttDiv.attr('id'), {
        title: {
            text: ganttDiv.data('title')
        },
        subtitle: {
            text: 'Source: Flow Climate'
        },

        yAxis: {
            uniqueNames: true
        },

        series: ganttDiv.data('series')
    });
};
