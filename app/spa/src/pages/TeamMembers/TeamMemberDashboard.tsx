import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"
import { Grid } from "@mui/material"

import { MeContext } from "../../contexts/MeContext"
import BasicPage from "../../components/BasicPage"
import Table from "../../components/Table"
import { TeamMember } from "../../modules/teamMember/teamMember.types"
import { secondsToDays } from "../../lib/date"

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
      demandLeadTimeP80
      startDate
      endDate
      projects {
        id
      }
      latestDeliveries: demands(status: FINISHED, limit: 8) {
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
  const demandShortestLeadTime =
    data?.teamMember?.demandShortestLeadTime?.leadtime || 0
  const demandLargestLeadTime =
    data?.teamMember?.demandLargestLeadTime?.leadtime || 0
  const demandLeadTimeP80 = data?.teamMember?.demandLeadTimeP80 || 0
  const teamMemberInfoRows = [
    [t("dashboard.name"), teamMemberName],
    [t("dashboard.delivered"), data?.teamMember?.deliveredDemands?.length || 0],
    [t("dashboard.bugs"), data?.teamMember?.bugs?.length || 0],
    [
      t("dashboard.leadTimeMin"),
      `${secondsToDays(demandShortestLeadTime)} ${t("dashboard.days")}`,
    ],
    [
      t("dashboard.leadTimeMax"),
      `${secondsToDays(demandLargestLeadTime)} ${t("dashboard.days")}`,
    ],
    [
      t("dashboard.leadTimeP80"),
      `${secondsToDays(demandLeadTimeP80)} ${t("dashboard.days")}`,
    ],
    [t("dashboard.startDate"), data?.teamMember?.startDate || ""],
    [t("dashboard.endDate"), data?.teamMember?.endDate || ""],
    [t("dashboard.projects"), data?.teamMember?.projects?.length || 0],
  ]

  const latestDeliveriesHeader = [
    t("dashboard.latestDeliveries.project"),
    t("dashboard.latestDeliveries.product"),
    t("dashboard.latestDeliveries.externalId"),
    t("dashboard.latestDeliveries.endDate"),
    t("dashboard.latestDeliveries.leadTime"),
  ]

  const latestDeliveriesRows =
    data?.teamMember?.latestDeliveries?.map((demand) => [
      demand.project?.name || "",
      demand.product?.name || "",
      demand.externalId || "",
      demand.endDate || "",
      secondsToDays(demand.leadtime) || "",
    ]) || []

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={teamMemberName}
      loading={loading}
    >
      <Grid container spacing={2}>
        <Grid item xs={6}>
          <Table rows={teamMemberInfoRows} />
        </Grid>
        <Grid item xs={6}>
          <Table
            headerCells={latestDeliveriesHeader}
            rows={latestDeliveriesRows}
          />
        </Grid>
      </Grid>
    </BasicPage>
  )
}

export default TeamMemberDashboard
