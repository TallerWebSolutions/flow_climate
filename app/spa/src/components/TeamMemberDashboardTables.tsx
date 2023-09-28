import { Button, FormGroup, Grid, Input, InputLabel, Link } from "@mui/material"
import { Link as RouterLink } from "react-router-dom"
import { useTranslation } from "react-i18next"

import { TeamMember } from "../modules/teamMember/teamMember.types"
import Table from "./ui/Table"
import { secondsToDays } from "../lib/date"
import DateLocale from "./ui/DateLocale"
import { FormElement } from "./ui/Form"
import { GridSearchIcon } from "@material-ui/data-grid"
import { FieldValues, useForm } from "react-hook-form"

type TeamMemberDashboardTablesProps = {
  teamMember: TeamMember
  effortsFilters: FieldValues
}

const TeamMemberDashboardTables = ({
  teamMember,
  effortsFilters,
}: TeamMemberDashboardTablesProps) => {
  const { t } = useTranslation(["teamMembers"])
  const { register } = useForm()

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
      teamMember.startDate ? <DateLocale date={teamMember.startDate} /> : "",
    ],
    [
      t("dashboard.endDate"),
      teamMember.endDate ? <DateLocale date={teamMember.endDate} /> : "",
    ],
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
      demand.endDate ? <DateLocale time date={demand.endDate} /> : 0,
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
      block.blockTime ? <DateLocale time date={block.blockTime} /> : "",
      block.unblockTime ? <DateLocale time date={block.unblockTime} /> : "",
    ]) || []

  const latestProjectsHeader = [
    t("dashboard.latestProjects.name"),
    t("dashboard.latestProjects.startDate"),
    t("dashboard.latestProjects.endDate"),
    t("dashboard.latestProjects.risk"),
    t("dashboard.latestProjects.quality"),
    t("dashboard.latestProjects.leadTime"),
  ]

  const latestEffortsHeader = [
    t("dashboard.latestEfforts.name"),
    t("dashboard.latestEfforts.team"),
    t("dashboard.latestEfforts.effortDate"),
    t("dashboard.latestEfforts.demands"),
    t("dashboard.latestEfforts.effortValue"),
  ]

  const latestEffortsRows =
    teamMember?.demandEffortsList?.map((effort) => [
      `${(effort.who || "")}`,
      <Link
        component={RouterLink}
        to={`/companies/taller/teams/${effort.team?.id}`}
      >
        {effort.team?.name}
      </Link>,
      <DateLocale date={String(effort.updatedAt)} />,
      <Link
        component={RouterLink}
        to={`/companies/taller/demands/${effort.demandExternalId}`}
      >
        {effort.demandExternalId}
      </Link>,
      `${(effort.effortValue || "")}`,
      
    ]) || []

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
      <Grid item xs={12}>
      <form>
        <FormGroup sx={{ marginBottom: 8 }}>
          <Grid container spacing={5}>
          <FormElement>
              <InputLabel htmlFor="startDate" shrink>
                {t("projectsTable.filter.startDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={effortsFilters.fromDate}
                {...register("fromDate")}
              />
            </FormElement>

            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {t("projectsTable.filter.endDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={effortsFilters.untilDate}
                {...register("untilDate")}
              />
            </FormElement>

            <FormElement>
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                <GridSearchIcon fontSize="large" color="primary" />
              </Button>
            </FormElement>

          </Grid>
        </FormGroup>
      </form>
      <Table
          title={t("dashboard.latestEfforts.title")}
          headerCells={latestEffortsHeader}
          rows={latestEffortsRows}
        />
      </Grid>
    </Grid>
  )
}

export default TeamMemberDashboardTables
