const initiativeCompletionTime = $("#initiative-tasks-completion-time");
if (initiativeCompletionTime.length !== 0) {
    buildLineChart(initiativeCompletionTime);
}

const initiativeTasksRisk = $("#initiative-tasks-risk");
if (initiativeTasksRisk.length !== 0) {
    buildLineChart(initiativeTasksRisk);
}

const initiativetasksBurnup = $("#initiative-burnup-tasks");
if (initiativetasksBurnup.length !== 0) {
    buildBurnupChart(initiativetasksBurnup);
}

const initiativetasksCompleted = $("#initiatives-completed");
if (initiativetasksCompleted.length !== 0) {
    buildDonutChart(initiativetasksCompleted);
}
