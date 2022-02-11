const tasksBasedScatterPlot = $("#tasks-completion-scatter");
if (tasksBasedScatterPlot.length !== 0) {
    buildScatterChart(tasksBasedScatterPlot);
}

const tasksListThroughput = $("#tasks-list-throughput-data-column");
if (tasksListThroughput.length !== 0) {
    buildColumnChart(tasksListThroughput);
};
