function buildOperationsCharts() {
    const pairingsDiv = $('#user-dashboard-pairing-column');
    if (pairingsDiv.length !== 0) {
        buildColumnChart(pairingsDiv);
    }

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated-user');
    if (lineLeadtimeAccumulated.length !== 0) {
        buildLineChart(lineLeadtimeAccumulated);
    }

    const userEffortDiv = $('#member-dashboard-effort-column');
    if (userEffortDiv.length !== 0) {
        buildColumnChart(userEffortDiv);
    }

    const teamMemberThroughputDiv = $('#member-dashboard-throughput-column');
    if (teamMemberThroughputDiv.length !== 0) {
        buildColumnChart(teamMemberThroughputDiv);
    }
}
