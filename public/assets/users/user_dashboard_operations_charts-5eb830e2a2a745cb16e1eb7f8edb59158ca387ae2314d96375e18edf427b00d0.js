function buildOperationsCharts() {
    const pairingsDiv = $('#user-dashboard-pairing-column');
    if (pairingsDiv.length !== 0) {
        buildColumnChart(pairingsDiv);
    }

    const lineLeadtimeAccumulated = $('#line-leadtime-accumalated-user');
    if (lineLeadtimeAccumulated.length !== 0) {
        buildLineChart(lineLeadtimeAccumulated);
    }
};
