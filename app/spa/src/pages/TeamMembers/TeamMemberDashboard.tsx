import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"

import { MeContext } from "../../contexts/MeContext"
import BasicPage from "../../components/BasicPage"
import Table from "../../components/Table"
import { TeamMember } from "../../modules/teamMember/teamMember.types"

const TEAM_MEMBER_QUERY = gql`
  query TeamMember($id: Int!) {
    teamMember(id: $id) {
      id
      name
      deliveredDemands: demands(status: FINISHED) {
        id
      }
      bugs: demands(status: FINISHED, type: BUG) {
        id
      }
      demandShortestLeadTime {
        id
        leadtime
      }
      demandLargestLeadTime {
        id
        leadtime
      }
    }
  }
`

type TeamMemberDTO = {
  teamMember: TeamMember
}

const TeamMemberDashboard = () => {
  const { t } = useTranslation(["teamMembers"])
  const { me } = useContext(MeContext)
  const { teamMemberId } = useParams()
  const { data, loading } = useQuery<TeamMemberDTO>(TEAM_MEMBER_QUERY, {
    variables: {
      id: Number(teamMemberId),
    },
  })
  const companySlug = me?.currentCompany?.slug
  const companyUrl = `/companies/${companySlug}`
  const teamMemberName = data?.teamMember?.name || ""
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("list.title"),
      url: `${companyUrl}/team_members`,
    },
    {
      name: teamMemberName,
    },
  ]
  const teamMemberInfoRows = [
    [t("dashboard.name"), teamMemberName],
    [t("dashboard.delivered"), data?.teamMember?.deliveredDemands?.length || 0],
    [t("dashboard.bugs"), data?.teamMember?.bugs?.length || 0],
    [
      t("dashboard.leadTimeMin"),
      data?.teamMember?.demandShortestLeadTime?.leadtime || 0,
    ],
    [
      t("dashboard.leadTimeMax"),
      data?.teamMember?.demandLargestLeadTime?.leadtime || 0,
    ],
  ]

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={teamMemberName}
      loading={loading}
    >
      <Table rows={teamMemberInfoRows} />
    </BasicPage>
  )
}

export default TeamMemberDashboard
