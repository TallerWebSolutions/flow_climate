function buildStatusReportDashboardHighcharts() {
    const scopeDiscoveredDiv = $('#status-report-scope-discovered-donut');
    buildDonutChart(scopeDiscoveredDiv);

    const demandsThroughputDiv = $('#status-report-dashboard-throughput-column');
    if (demandsThroughputDiv.length !== 0) {
        buildColumnChart(demandsThroughputDiv);
    }
};
