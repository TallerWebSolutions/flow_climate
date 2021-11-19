function searchProjects(
  companyId,
  projectsIds,
  startDate,
  endDate,
  projectStatus,
  projectName,
  targetName
) {
  $("#general-loader").show();

  jQuery.ajax({
    url: `/companies/${companyId}/projects/search_projects.js`,
    type: "GET",
    data: `projects_ids=${projectsIds}&start_date=${startDate}&end_date=${endDate}&project_status=${projectStatus}&project_name=${projectName}&target_name=${targetName}`,
  });
}

const searchProjectsByTeam = (companyId, teamId) => {
  $("#general-loader").show();

  jQuery.ajax({
    url: `/companies/${companyId}/projects/search_projects_by_team.js`,
    type: "GET",
    data: `team_id=${teamId}`,
  });
};
