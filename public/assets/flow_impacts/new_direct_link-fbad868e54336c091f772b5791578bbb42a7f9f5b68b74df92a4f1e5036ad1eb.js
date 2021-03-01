$(".projects_select").on("change", function (){

    let companyId = $("#company_id").val()
    let projectId = this.value

    jQuery.ajax({
        url: `/companies/${companyId}/projects/${projectId}/flow_impacts/demands_to_project.js`,
        type: "GET"
    });
});
