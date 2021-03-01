function buildStrategicCharts(companyId, projectsIds, teamsIds, targetName, period, startDate, endDate) {
    jQuery.ajax({
        url: `/companies/${companyId}/build_strategic_charts.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}&teams_ids=${teamsIds}&target_name=${targetName}&period=${period}&start_date=${startDate}&end_date=${endDate}&period=${period}`
    });
};
