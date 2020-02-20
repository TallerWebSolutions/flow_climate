function buildManagerCharts() {
    const projectsQuality = $('#manager-dashboard-quality-column');
    if (projectsQuality.length !== 0) {
        buildColumnChart(projectsQuality);
    }

    const projectsLeadTime = $('#manager-dashboard-lead-time-column');
    if (projectsLeadTime.length !== 0) {
        buildColumnChart(projectsLeadTime);
    }

    const projectsRisk = $('#manager-dashboard-risk-column');
    if (projectsRisk.length !== 0) {
        buildColumnChart(projectsRisk);
    }

    const projectsScope = $('#manager-dashboard-scope-column');
    if (projectsScope.length !== 0) {
        buildColumnChart(projectsScope);
    }

    const projectsValuePerDemand = $('#manager-dashboard-value-per-demand-column');
    if (projectsValuePerDemand.length !== 0) {
        buildColumnChart(projectsValuePerDemand);
    }

    const projectsFlowPressure = $('#manager-dashboard-flow-pressure-column');
    if (projectsFlowPressure.length !== 0) {
        buildColumnChart(projectsFlowPressure);
    }
}