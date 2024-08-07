const tasksBasedScatterPlot = $("#tasks-completion-scatter");
if (tasksBasedScatterPlot.length !== 0) {
    buildScatterChart(tasksBasedScatterPlot);
}

const tasksWipBasedScatterPlot = $("#tasks-wip-completion-scatter");
if (tasksWipBasedScatterPlot.length !== 0) {
    buildScatterChart(tasksWipBasedScatterPlot);
}

const tasksListThroughput = $("#tasks-list-throughput-data-column");
if (tasksListThroughput.length !== 0) {
    buildColumnChart(tasksListThroughput);
}

const completionTimeEvolution = $("#tasks-list-completion-time-evolution");
if (completionTimeEvolution.length !== 0) {
    buildLineChart(completionTimeEvolution);
};
