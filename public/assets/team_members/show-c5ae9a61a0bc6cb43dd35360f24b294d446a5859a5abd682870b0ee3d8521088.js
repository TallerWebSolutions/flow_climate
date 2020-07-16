const pairingsDiv = $('#user-dashboard-pairing-column');
if (pairingsDiv.length !== 0) {
    buildColumnChart(pairingsDiv);
}

const lineLeadtimeAccumulated = $('#line-leadtime-accumalated-user');
if (lineLeadtimeAccumulated.length !== 0) {
    buildLineChart(lineLeadtimeAccumulated);
}

const linePullInterval = $('#member-dashboard-pull-interval-line');
if (linePullInterval.length !== 0) {
    buildLineChart(linePullInterval);
}

const teamMemberEffortDiv = $('#member-dashboard-effort-column');
if (teamMemberEffortDiv.length !== 0) {
    buildColumnChart(teamMemberEffortDiv);
}

const teamMemberThroughputDiv = $('#member-dashboard-throughput-column');
if (teamMemberThroughputDiv.length !== 0) {
    buildColumnChart(teamMemberThroughputDiv);
};
