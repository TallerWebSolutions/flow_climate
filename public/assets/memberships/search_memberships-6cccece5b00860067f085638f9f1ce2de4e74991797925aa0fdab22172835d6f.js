function searchMembershipsClick(companyId, teamId) {
    let membershipStatus = $("#active_memberships").is(":checked");

    searchMembershipsStatus(companyId, teamId, membershipStatus);
};
