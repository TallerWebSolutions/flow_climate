import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"

import { MeContext } from "../../contexts/MeContext"
import BasicPage from "../../components/BasicPage"
import { TeamMember } from "../../modules/teamMember/teamMember.types"
import TeamMemberDashboardTables from "../../components/TeamMemberDashboardTables"
import TeamMemberDashboardCharts from "../../components/TeamMemberDashboardCharts"

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
      leadTimeHistogramChartData {
        keys
        values
      }
      leadTimeControlChartData {
        xAxis
        yAxis
      }
      demandLeadTimeP80
      startDate
      endDate
      projectsList(orderField: "end_date", sortDirection: DESC) {
        totalCount
        projects {
          id
          name
          startDate
          endDate
          currentRiskToDeadline
          leadTimeP80
        }
      }
      teams {
        id
        name
      }
      demandBlocksList(
        orderField: "block_time"
        sortDirection: DESC
        perPage: 6
      ) {
        demandBlocks {
          id
          demand {
            id
            demandTitle
          }
          blockTime
          unblockTime
        }
      }
      latestDeliveries: demands(status: FINISHED, limit: 10) {
        id
        project {
          id
          name
        }
        product {
          id
          name
        }
        externalId
        endDate
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

  const teamMember = data?.teamMember

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={teamMemberName}
      loading={loading}
    >
      {teamMember && (
        <>
          <TeamMemberDashboardTables teamMember={teamMember} />
          <TeamMemberDashboardCharts teamMember={teamMember} />
        </>
      )}
    </BasicPage>
  )
}

export default TeamMemberDashboard
