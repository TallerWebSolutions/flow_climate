import { Grid, Link } from "@mui/material"
import { Link as RouterLink } from "react-router-dom"
import { useTranslation } from "react-i18next"

import { TeamMember } from "../modules/teamMember/teamMember.types"
import Table from "./ui/Table"
import { secondsToDays } from "../lib/date"
import DateLocale from "./ui/DateLocale"

type TeamMemberDashboardTablesProps = {
  teamMember: TeamMember
}

const TeamMemberDashboardTables = ({
  teamMember,
}: TeamMemberDashboardTablesProps) => {
  const { t } = useTranslation(["teamMembers"])
  const demandShortestLeadTime =
    teamMember.demandShortestLeadTime?.leadtime || 0
  const demandLargestLeadTime = teamMember.demandLargestLeadTime?.leadtime || 0
  const demandLeadTimeP80 = teamMember.demandLeadTimeP80 || 0
  const teamMemberInfoRows = [
    [t("dashboard.name"), teamMember.name],
    [t("dashboard.delivered"), teamMember.deliveredDemands?.length || 0],
    [t("dashboard.bugs"), teamMember.bugs?.length || 0],
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
      <DateLocale date={teamMember.startDate || ""} />,
    ],
    [t("dashboard.endDate"), <DateLocale date={teamMember.endDate || ""} />],
    [t("dashboard.projects"), teamMember.projectsList?.totalCount || 0],
  ]

  const latestDeliveriesHeader = [
    t("dashboard.latestDeliveries.project"),
    t("dashboard.latestDeliveries.product"),
    t("dashboard.latestDeliveries.externalId"),
    t("dashboard.latestDeliveries.endDate"),
    t("dashboard.latestDeliveries.leadTime"),
  ]

  const latestDeliveriesRows =
    teamMember.latestDeliveries?.map((demand) => [
      <Link
        component={RouterLink}
        to={`/companies/${demand.company?.slug}/projects/${demand.project?.id}`}
      >
        {demand.project?.name}
      </Link>,
      <Link
        component={RouterLink}
        to={`/companies/${demand.company?.slug}/products/${demand.product?.id}`}
      >
        {demand.product?.name}
      </Link>,
      demand.externalId || "",
      <DateLocale time date={demand.endDate} />,
      `${secondsToDays(demand.leadtime)} ${t("dashboard.days")}`,
    ]) || []

  const teamsRows =
    teamMember.teams?.map((team) => [
      <Link
        to={`/companies/${team.company?.slug}/teams/${team.id}`}
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
    teamMember.demandBlocksList?.demandBlocks?.map((block) => [
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
    teamMember.projectsList?.projects?.map((project) => [
      <Link
        component={RouterLink}
        to={`/companies/${project.company?.slug}/projects/${project.id}`}
      >
        {project.name}
      </Link>,
      <DateLocale date={project.startDate} />,
      <DateLocale date={project.endDate} />,
      `${(project.currentRiskToDeadline || 0 * 100).toFixed(2)}%`,
      `${(project.quality || 0 * 100).toFixed(2)}%`,
      `${secondsToDays(project.leadTimeP80)} ${t("dashboard.days")}`,
    ]) || []
  return (
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
  )
}

export default TeamMemberDashboardTables
