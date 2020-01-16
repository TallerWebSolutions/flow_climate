const pairingsDiv = $('#user-dashboard-pairing-column');
if (pairingsDiv) {
    buildColumnChart(pairingsDiv);
}

const lineLeadtimeAccumulated = $('#line-leadtime-accumalated-user');
if (lineLeadtimeAccumulated.length !== 0) {
    buildLineChart(lineLeadtimeAccumulated);
}

