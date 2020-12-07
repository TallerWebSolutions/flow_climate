function buildManagerCharts() {
    const projectsQuality = $('#manager-dashboard-quality-line');
    if (projectsQuality.length !== 0) {
        buildLineChart(projectsQuality);
    }

    const projectsLeadTime = $('#manager-dashboard-lead-time-line');
    if (projectsLeadTime.length !== 0) {
        buildLineChart(projectsLeadTime);
    }

    const projectsRisk = $('#manager-dashboard-risk-line');
    if (projectsRisk.length !== 0) {
        buildLineChart(projectsRisk);
    }

    const projectsScope = $('#manager-dashboard-scope-line');
    if (projectsScope.length !== 0) {
        buildLineChart(projectsScope);
    }

    const projectsValuePerDemand = $('#manager-dashboard-value-per-demand-line');
    if (projectsValuePerDemand.length !== 0) {
        buildLineChart(projectsValuePerDemand);
    }

    const projectsFlowPressure = $('#manager-dashboard-flow-pressure-line');
    if (projectsFlowPressure.length !== 0) {
        buildLineChart(projectsFlowPressure);
    }
}