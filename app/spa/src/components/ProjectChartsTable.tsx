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
import { formatDate, secondsToDays } from "../lib/date"
import { DemandsList } from "../modules/demand/demand.types"
import { Project } from "../modules/project/project.types"
import { ReadMoreButton } from "./ReadMoreButton"
import { PROJECT_STANDARD_FRAGMENT } from "./ProjectPage"
import LatestDeliveriesTable from "../modules/demand/components/LatestDeliveriesTable"

const LIMIT_DEMANDS_PER_PAGE = 10

const PROJECT_CHART_QUERY = gql`
  query ProjectCharts($projectId: ID!, $limit: Int!) {
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

    demandsList(
      searchOptions: {
        projectId: $projectId
        perPage: $limit
        demandStatus: DELIVERED_DEMANDS
        orderField: "endDate"
        sortDirection: DESC
      }
    ) {
      demands {
        id
        externalId
        customerName
        productName
        projectName
        endDate
        leadtime
        demandBlocksCount
        product {
          id
          name
        }
        customer {
          id
          name
        }
      }
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type MountSearchLinkProps = {
  companySlug: string
  state?: string
  projectID: string
}

type ProjectChartResult = {
  project: Project
  demandsList: DemandsList
  hoursPerCoordinationStageChartData: Pick<Project, "hoursPerStageChartData">
}

type ProjectChartDTO = ProjectChartResult | undefined

const mountDemandsSearchLink = ({
  state,
  projectID,
  companySlug,
}: MountSearchLinkProps) => {
  return (
    `/companies/${companySlug}/demands` +
    `?searchText=&project=${projectID}&state=${state}`
  )
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
  const { t } = useTranslation(["projectChart"])
  const { t: tDemands } = useTranslation(["demand"])
  const [readMore, setReadMore] = useState(true)
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectChartDTO>(PROJECT_CHART_QUERY, {
    variables: {
      projectId,
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
  const latestDeliveries = data?.demandsList.demands || []

  if (!project) return <div>Project not found</div>

  const projectID = project.id
  const companySlug = project.company?.slug || ""
  const baseLink = `/companies/${project?.company?.slug}`

  return (
    <Grid container spacing={2}>
      <Grid item xs={4} sx={{ padding: "16px" }}>
        <TableContainer
          component={Paper}
          sx={{ background: "white", marginY: 4 }}
        >
          <Typography
            color="primary"
            variant="h6"
            component="h6"
            sx={{ padding: "16px " }}
          >
            {t("details.generalInfo")}
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
                <Cell>{t("details.start")}</Cell>
                <Cell align="right">
                  {formatDate({
                    date: project.startDate,
                    format: "dd/MM/yyyy",
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">{t("details.end")}</Box>
                </Cell>
                <Cell align="right">
                  {formatDate({ date: project.endDate, format: "dd/MM/yyyy" })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">{t("details.initialScope")}</Box>
                </Cell>
                <Cell align="right">{project.initialScope}</Cell>
              </Row>
              <Row>
                <Cell>
                  <Box component="span">
                    {tDemands("list.demandsTable.createdDemands")}
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
                <Cell>{tDemands("list.demandsTable.deliveredDemands")}</Cell>
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
                    {tDemands("list.demandsTable.backlog")}
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
                    {tDemands("list.demandsTable.upstreamDemands")}
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
                    {tDemands("list.demandsTable.downstreamDemands")}
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
                <Cell>{tDemands("list.demandsTable.discardedDemands")}</Cell>
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
                <Cell>{tDemands("list.demandsTable.unscoredDemands")}</Cell>
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
                <Cell>{tDemands("list.demandsTable.demandBlocks")}</Cell>
                <Cell align="right">
                  <Link
                    href={`/companies/${companySlug}/demand_blocks`}
                    sx={{ color: "info.dark", textDecoration: "none" }}
                  >
                    {project.demandBlocks.length}
                  </Link>
                </Cell>
              </Row>
              <Row>
                <Cell>{t("details.flowPressure")}</Cell>
                <Cell align="right">{project.flowPressure.toFixed(2)}</Cell>
              </Row>
              <Row>
                <Cell>
                  {tDemands("list.demandsTable.averageSpeed", {
                    numberOfDemandsPerDay: project.averageSpeed.toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {tDemands("list.demandsTable.averageQueueTime", {
                    time: secondsToDays(project.averageQueueTime).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {tDemands("list.demandsTable.averageWorkTime", {
                    time: secondsToDays(project.averageTouchTime).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {tDemands("list.demandsTable.leadTimeP95", {
                    days: secondsToDays(project.leadTimeP95).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {tDemands("list.demandsTable.leadTimeP80", {
                    days: secondsToDays(project.leadTimeP80).toFixed(2),
                  })}
                </Cell>
              </Row>
              <Row>
                <Cell>
                  {tDemands("list.demandsTable.leadTimeP65", {
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
        <LatestDeliveriesTable demands={latestDeliveries} baseLink={baseLink} />
      </Grid>
    </Grid>
  )
}
