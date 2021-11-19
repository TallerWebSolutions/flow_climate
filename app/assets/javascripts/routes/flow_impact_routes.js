function getFlowEvents(companyId, projectId, projectsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/flow_events/flow_events_tab.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}&project_id=${projectId}`
    });
}
