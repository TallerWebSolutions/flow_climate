import { useState } from "react"
import {
  Box,
  Grid,
  Link,
  Paper,
  Table as MUITable,
  TableCell,
  TableCellProps,
  TableContainer,
  TableRow,
  TableRowProps,
  Typography,
} from "@mui/material"
import { gql, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { Backdrop, CircularProgress } from "@mui/material"
import { formatDate, secondsToDays, secondsToReadbleDate } from "../lib/date"
import { Demand } from "../modules/demand/demand.types"
import { Project } from "../modules/project/project.types"
import { ReadMoreButton } from "./ReadMoreButton"
import Table from "./Table"
import { PROJECT_STANDARD_FRAGMENT } from "./ProjectPage"

const LIMIT_DEMANDS_PER_PAGE = 10

const PROJECT_CHART_QUERY = gql`
  query ProjectCharts($projectId: Int!, $limit: Int!) {
    project(id: $projectId) {
      ...ProjectStandardFragment
      startDate
      endDate
      initialScope
      numberOfDemands
      numberOfDemandsDelivered
      remainingBacklog
      projectMembers {
        demandsCount
        memberName
      }
      upstreamDemands {
        id
      }
      numberOfDownstreamDemands
      discardedDemands {
        id
      }
      unscoredDemands {
        id
      }
      demandBlocks {
        id
      }
      flowPressure
      averageSpeed
      averageQueueTime
      averageTouchTime
      leadTimeP65
      leadTimeP80
      leadTimeP95
    }

    demands(projectId: $projectId, limit: $limit, finished: true) {
      id
      endDate
      product {
        id
        name
      }
      customer {
        id
        name
      }
      externalId
      leadtime
      numberOfBlocks
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type MountSearchLinkProps = {
  companySlug: string
  state: string
  projectID: string
}

type ProjectChartResult = {
  project: Project
  demands: Demand[]
  hoursPerCoordinationStageChartData: Pick<Project, "hoursPerStageChartData">
}

type ProjectChartDTO = ProjectChartResult | undefined

const mountDemandsSearchLink = ({
  state,
  projectID,
  companySlug,
}: MountSearchLinkProps) => {
  return `/companies/${companySlug}/demands/demands_list_by_ids?demand_fitness=&demand_state=${state}&demand_type=&flow_object_id=${projectID}&object_type=Project`
}

const Row = (props: TableRowProps) => (
  <TableRow
    sx={{
      borderBottom: "1px solid",
      borderBottomColor: "#ccc",
    }}
    {...props}
  />
)

const Cell = (props: TableCellProps) => (
  <TableCell
    sx={{
      padding: 2,
    }}
    {...props}
  />
)

export const ProjectChartsTable = () => {
  const { t } = useTranslation(["project"])
  const [readMore, setReadMore] = useState(true)
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectChartDTO>(PROJECT_CHART_QUERY, {
    variables: {
      projectId: Number(projectId),
      limit: LIMIT_DEMANDS_PER_PAGE,
    },
  })

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const project = data?.project
  const demands = data?.demands || []

  if (!project) return <div>Project not found</div>

  const projectID = project.id
  const companySlug = project.company.slug

  const latestDeliveriesHeaderCells = [
    t("charts_tab.project_chart_table.demand_id"),
    t("charts_tab.project_chart_table.client"),
    t("charts_tab.project_chart_table.product"),
    t("charts_tab.project_chart_table.delivery_date"),
    t("charts_tab.project_chart_table.leadtime"),
    t("charts_tab.project_chart_table.demand_blocks"),
  ]

  const baseLink = `/companies/${project?.company?.slug}`
  const latestDeliveriesRows = demands.map((demand) => {
    return [
      <Link
        href={`${baseLink}/demands/${demand.externalId}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.externalId}
      </Link>,
      <Link
        href={`${baseLink}/projects/${project.id}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.customer?.name}
      </Link>,
      <Link
        href={`${baseLink}/products/${demand.product.id}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.product.name}
      </Link>,
      formatDate({
        date: demand.endDate,
        format: "dd/MM/yyyy' 'HH:mm:ss",
      }),
      secondsToReadbleDate(demand.leadtime),
      demand.numberOfBlocks,
    ]
  })

  return (
    <Grid container spacing={2} sx={{ marginTop: "32px" }}>
      <Grid item xs={4} sx={{ padding: "16px " }}>
        <TableContainer component={Paper} sx={{ background: "white" }}>
          <Typography
            color="primary"
            variant="h6"
            component="h6"
            sx={{ padding: "16px " }}
          >
            {t("charts_tab.project_chart_table.general_info")}
          </Typography>
          <Box
            sx={{
              position: "relative",
              height: readMore ? "586px" : "auto",
              overflow: readMore ? "hidden" : "",
            }}
          >
            <MUITable>
              <Row>
                <Cell>{t("charts_tab.project_chart_table.start")}</Cell>
                <Cell align="right">
                  {formatDate({
                    date: project.startDate,
                    format: "dd/MM/yyyy",
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">
                    {t("charts_tab.project_chart_table.end")}
                  </Box>
                </Cell>
                <Cell align="right">
                  {formatDate({ date: project.endDate, format: "dd/MM/yyyy" })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">
                    {t("charts_tab.project_chart_table.initial_scope")}
                  </Box>
                </Cell>
                <Cell align="right">{project.initialScope}</Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">
                    {t("charts_tab.project_chart_table.created_demands")}
                  </Box>
                </Cell>
                <Cell align="right">
                  <Link
                    href={mountDemandsSearchLink({
                      projectID,
                      companySlug,
                      state: "created",
                    })}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.numberOfDemands}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.delivered_demands")}
                </Cell>
                <Cell align="right">
                  <Link
                    href={mountDemandsSearchLink({
                      projectID,
                      companySlug,
                      state: "delivered",
                    })}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.numberOfDemandsDelivered}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">
                    {t("charts_tab.project_chart_table.backlog")}
                  </Box>
                </Cell>
                <Cell align="right">
                  <Link
                    href={mountDemandsSearchLink({
                      projectID,
                      companySlug,
                      state: "backlog",
                    })}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.remainingBacklog}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">
                    {t("charts_tab.project_chart_table.upstream_demands")}
                  </Box>
                </Cell>
                <Cell align="right">
                  <Link
                    href={mountDemandsSearchLink({
                      projectID,
                      companySlug,
                      state: "upstream",
                    })}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.upstreamDemands.length}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">
                    {t("charts_tab.project_chart_table.downstream_demands")}
                  </Box>
                </Cell>
                <Cell align="right">
                  <Link
                    href={mountDemandsSearchLink({
                      projectID,
                      companySlug,
                      state: "downstream",
                    })}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.numberOfDownstreamDemands}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.discarted_demands")}
                </Cell>
                <Cell align="right">
                  <Link
                    href={mountDemandsSearchLink({
                      projectID,
                      companySlug,
                      state: "discarded",
                    })}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.discardedDemands.length}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.unscored_demands")}
                </Cell>
                <Cell align="right">
                  <Link
                    href={mountDemandsSearchLink({
                      projectID,
                      companySlug,
                      state: "unscored",
                    })}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.unscoredDemands.length}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.blocked_demands")}
                </Cell>
                <Cell align="right">
                  <Link
                    href={`/companies/${companySlug}/demand_blocks/search?demand_blocks_ids=${project.demandBlocks
                      .map((el) => el.id)
                      .join()}`}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.demandBlocks.length}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>{t("charts_tab.project_chart_table.flow_pressure")}</Cell>
                <Cell align="right">{project.flowPressure.toFixed(2)}</Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.average_speed", {
                    numberOfDemandsPerDay: project.averageSpeed.toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.average_queue_time", {
                    time: secondsToDays(project.averageQueueTime).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.average_work_time", {
                    time: secondsToDays(project.averageTouchTime).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.lead_time_p95", {
                    days: secondsToDays(project.leadTimeP95).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.lead_time_p80", {
                    days: secondsToDays(project.leadTimeP80).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {t("charts_tab.project_chart_table.lead_time_p65", {
                    days: secondsToDays(project.leadTimeP65).toFixed(2),
                  })}
                </Cell>
              </Row>
            </MUITable>
            {readMore && (
              <ReadMoreButton
                handleDisplayPostContent={() => setReadMore(false)}
              />
            )}
          </Box>
        </TableContainer>
      </Grid>

      <Grid item xs={8} sx={{ padding: "16px " }}>
        <Table
          title={t("charts_tab.project_chart_table.latest_deliveries")}
          headerCells={latestDeliveriesHeaderCells}
          rows={latestDeliveriesRows}
        />
      </Grid>
    </Grid>
  )
}
