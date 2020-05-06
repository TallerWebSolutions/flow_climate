function searchMembershipsStatus(companyId, teamId, membershipStatus) {
    jQuery.ajax({
        url: `/companies/${companyId}/teams/${teamId}/memberships/search_memberships.js`,
        type: "GET",
        data: `&membership_status=${membershipStatus}`
    });
};
