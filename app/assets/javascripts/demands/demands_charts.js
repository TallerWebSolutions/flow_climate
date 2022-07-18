function buildDemandsTabCharts() {
    const demandsThroughputDiv = $('#demands-throughput-column');
    if (demandsThroughputDiv.length !== 0) {
        buildColumnChart(demandsThroughputDiv);
    }

    const demandsCreatedDiv = $('#demands-created-column');
    if (demandsCreatedDiv.length !== 0) {
        buildColumnChart(demandsCreatedDiv);
    }

    const demandsCommittedDiv = $('#demands-committed-column');
    if (demandsCommittedDiv.length !== 0) {
        buildColumnChart(demandsCommittedDiv);
    }

    const leadtimeEvolution = $('#leadtime-evolution');
    if (leadtimeEvolution.length !== 0) {
        buildLineChart(leadtimeEvolution);
    }

    const demandsByProject = $('#demands-by-project');
    if (demandsByProject.length !== 0) {
        buildColumnChart(demandsByProject);
    }

    let donutDemandTypeDiv = $('#demands-type-donut');
    if (donutDemandTypeDiv.length !== 0) {
        buildDonutChart(donutDemandTypeDiv);
    }

    let donutDemandDeliveredDiv = $('#demands-delivered-donut');
    if (donutDemandDeliveredDiv.length !== 0) {
        buildDonutChart(donutDemandDeliveredDiv);
    }

    const leadtimeControlChart = $('#leadtime-control-chart');
    if (leadtimeControlChart.length !== 0) {
        buildScatterChart(leadtimeControlChart);
    }
}
