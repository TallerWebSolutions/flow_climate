function getDemands(company_id, projects_ids) {
    $(".loader").show();

    jQuery.ajax({
        url: "/companies/" + company_id + "/demands/demands_in_projects" + ".js",
        type: "GET",
        data: 'projects_ids=' + projects_ids
    });
}
