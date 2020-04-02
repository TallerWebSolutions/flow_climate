function searchTeamMembersClick(companyId) {
    let teamMemberStatus = $("#active_members").is(":checked");

    searchTeamMembersStatus(companyId, teamMemberStatus);
}
