import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { useParams, Link as RouterLink } from "react-router-dom"
import { Grid, Link } from "@mui/material"

import { MeContext } from "../../contexts/MeContext"
import BasicPage from "../../components/BasicPage"
import Table from "../../components/Table"
import { TeamMember } from "../../modules/teamMember/teamMember.types"
import { secondsToDays } from "../../lib/date"
import DateLocale from "../../components/ui/DateLocale"

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
      projects(orderField: "end_date", sortDirection: DESC) {
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
      demandBlocks {
        id
        demand {
          id
          demandTitle
        }
        blockTime
        unblockTime
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
    [
      t("dashboard.startDate"),
      <DateLocale date={data?.teamMember?.startDate || ""} />,
    ],
    [
      t("dashboard.endDate"),
      <DateLocale date={data?.teamMember?.endDate || ""} />,
    ],
    [t("dashboard.projects"), data?.teamMember?.projects?.totalCount || 0],
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
      <Link
        component={RouterLink}
        to={`/companies/${companySlug}/projects/${demand.project?.id}`}
      >
        {demand.project?.name}
      </Link>,
      <Link
        component={RouterLink}
        to={`/companies/${companySlug}/products/${demand.product?.id}`}
      >
        {demand.product?.name}
      </Link>,
      demand.externalId || "",
      <DateLocale time date={demand.endDate} />,
      `${secondsToDays(demand.leadtime)} ${t("dashboard.days")}`,
    ]) || []

  const teamsRows =
    data?.teamMember?.teams?.map((team) => [
      <Link
        to={`/companies/${companySlug}/teams/${team.id}`}
        component={RouterLink}
      >
        {team.name}
      </Link>,
    ]) || []

  const demandBlocksHeader = [
    t("dashboard.demandBlocks.demandName"),
    t("dashboard.demandBlocks.blockTime"),
    t("dashboard.demandBlocks.unblockTime"),
  ]
  const demandBlocksRows =
    data?.teamMember?.demandBlocks?.map((block) => [
      block.demand?.demandTitle || "",
      <DateLocale time date={block.blockTime} />,
      <DateLocale time date={block.unblockTime} />,
    ]) || []

  const latestProjectsHeader = [
    t("dashboard.latestProjects.name"),
    t("dashboard.latestProjects.startDate"),
    t("dashboard.latestProjects.endDate"),
    t("dashboard.latestProjects.risk"),
    t("dashboard.latestProjects.quality"),
    t("dashboard.latestProjects.leadTime"),
  ]
  const latestProjectsRows =
    data?.teamMember?.projects?.projects?.map((project) => [
      <Link
        component={RouterLink}
        to={`/companies/${companySlug}/projects/${project.id}`}
      >
        {project.name}
      </Link>,
      <DateLocale date={project.startDate} />,
      <DateLocale date={project.endDate} />,
      `${(project.currentRiskToDeadline * 100).toFixed(2)}%`,
      "",
      `${secondsToDays(project.leadTimeP80)} ${t("dashboard.days")}`,
    ]) || []

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={teamMemberName}
      loading={loading}
    >
      <Grid container columnSpacing={4}>
        <Grid item xs={3}>
          <Table
            title={t("dashboard.memberInfoTitle")}
            rows={teamMemberInfoRows}
          />
        </Grid>
        <Grid item xs={3}>
          <Table title={t("dashboard.teams.title")} rows={teamsRows} />
        </Grid>
        <Grid item xs={6}>
          <Table
            title={t("dashboard.demandBlocks.title")}
            headerCells={demandBlocksHeader}
            rows={demandBlocksRows}
          />
        </Grid>
        <Grid item xs={6}>
          <Table
            title={t("dashboard.latestDeliveries.title")}
            headerCells={latestDeliveriesHeader}
            rows={latestDeliveriesRows}
          />
        </Grid>
        <Grid item xs={6}>
          <Table
            title={t("dashboard.latestProjects.title")}
            headerCells={latestProjectsHeader}
            rows={latestProjectsRows}
          />
        </Grid>
      </Grid>
    </BasicPage>
  )
}

export default TeamMemberDashboard
