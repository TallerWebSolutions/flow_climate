function bindSearchProjects() {
    $('#search-projects').on("click", function(){
        let companyId = $("#company_id").val();
        let projectsIds = $("#projects_ids").val();
        let startDate = $("#projects_filter_start_date").val();
        let endDate = $("#projects_filter_end_date").val();
        let projectStatus = $("#projects_filter_status").val();
        let projectName = $("#project_name").val();
        let targetName = $("#target_name").val();

        searchProjects(companyId, projectsIds, startDate, endDate, projectStatus, projectName, targetName)
    })
};
