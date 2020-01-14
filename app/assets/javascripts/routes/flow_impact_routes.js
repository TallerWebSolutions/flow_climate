function getFlowImpacts(companyId, projectId, projectsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/flow_impacts/flow_impacts_tab.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}&project_id=${projectId}`
    });
}
