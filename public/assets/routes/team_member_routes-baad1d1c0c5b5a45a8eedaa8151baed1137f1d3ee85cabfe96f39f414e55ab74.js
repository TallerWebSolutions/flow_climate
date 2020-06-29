function searchTeamMembersStatus(companyId, teamMemberStatus) {
    jQuery.ajax({
        url: `/companies/${companyId}/team_members/search_team_members.js`,
        type: "GET",
        data: `&team_member_status=${teamMemberStatus}`
    });
};
