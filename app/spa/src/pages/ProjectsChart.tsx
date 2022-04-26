import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  Box,
  CircularProgress,
  Grid,
  Typography,
} from "@mui/material"
import { BarDatum } from "@nivo/bar"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { BarChart } from "../components/charts/BarChart"
import { LineChart, LineGraphProps } from "../components/charts/LineChart"
import { ScatterChart } from "../components/charts/ScatterChart"
import { ProjectChartsTable } from "../components/ProjectChartsTable"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../components/ProjectPage"
import { secondsToDays } from "../lib/date"
import { Demand } from "../modules/demand/demand.types"
import { Project } from "../modules/project/project.types"
import { buildPercentileYAxisMarker } from "./Tasks/Charts"

const LIMIT_DEMANDS_PER_PAGE = 10

export const PROJECT_CHART_QUERY = gql`
  query ProjectCharts($projectId: Int!, $limit: Int!) {
    project(id: $projectId) {
      ...ProjectStandardFragment
      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running

      startDate
      endDate
      initialScope
      numberOfDemands
      numberOfDemandsDelivered
      remainingBacklog
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

      projectConsolidationsWeekly {
        leadTimeP80
        projectQuality
        consolidationDate
        operationalRisk
        tasksBasedOperationalRisk
        codeNeededBlocksCount
        codeNeededBlocksPerDemand
        flowEfficiency
        hoursPerDemand
        projectThroughput
        projectThroughputHours
        bugsOpened
        bugsClosed
        projectThroughputHoursManagement
        projectThroughputHoursDevelopment
        projectThroughputHoursDesign
      }

      projectConsolidationsLastMonth {
        consolidationDate
        projectThroughputHoursInMonth
        projectThroughputHoursManagementInMonth
        projectThroughputHoursDevelopmentInMonth
        projectThroughputHoursDesignInMonth

        projectThroughputHoursManagement
        projectThroughputHoursDevelopment
        projectThroughputHoursDesign
      }

      lastProjectConsolidationsWeekly {
        leadTimeP65
        leadTimeP80
        leadTimeP95
      }

      demandsFinishedWithLeadtime {
        id
        leadtime
        externalId
      }

      hoursPerStageChartData {
        xAxis
        yAxis
      }

      weeklyProjectScopeUntilEnd
      currentWeeklyScopeIdealBurnup
      currentWeeklyHoursIdealBurnup
      weeklyProjectScopeHoursUntilEnd
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

type ProjectChartResult = {
  project: Project
  demands: Demand[]
}

type ProjectChartDTO = ProjectChartResult | undefined

type ChartLineboxProps = {
  title: string
} & LineGraphProps

const ChartLineBox = ({
  title,
  data,
  axisLeftLegend,
  props,
}: ChartLineboxProps) => {
  return (
    <Grid item xs={6} sx={{ padding: "8px" }}>
      <Box sx={{ height: "350px" }}>
        <Typography>{title}</Typography>

        <LineChart data={data} axisLeftLegend={axisLeftLegend} {...props} />
      </Box>
    </Grid>
  )
}

const ProjectsChart = () => {
  const { t } = useTranslation(["projectChart"])
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

  const project = data?.project!
  const projectConsolidationsWeekly = project?.projectConsolidationsWeekly || []
  const projectConsolidationsLastMonth = project?.projectConsolidationsLastMonth
  const demandsFinishedWithLeadtime = project?.demandsFinishedWithLeadtime
  const lastProjectConsolidationsWeekly =
    project?.lastProjectConsolidationsWeekly
  const hoursPerStageChartData = project?.hoursPerStageChartData
  const demands = data?.demands!

  const operationalRiskChartData = [
    {
      id: "Operational Math Risk Evolution",
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, operationalRisk }) => {
          const operationalRiskInPercentage = (operationalRisk * 100).toFixed(2)

          return {
            x: consolidationDate,
            y: operationalRiskInPercentage,
          }
        }
      ),
    },
  ]

  const operationalTeamRiskChartData = [
    {
      id: "Operational Risk (%)",
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, tasksBasedOperationalRisk }) => {
          const operationalTeamRiskInPercentage: string = (
            tasksBasedOperationalRisk * 100
          ).toFixed(2)

          return {
            x: consolidationDate,
            y: operationalTeamRiskInPercentage,
          }
        }
      ),
    },
  ]

  const projectBugsChartData: BarDatum[] = projectConsolidationsWeekly.map(
    ({ bugsOpened, bugsClosed }, index) => {
      return {
        index: index,
        "Bugs Openned": bugsOpened,
        "Bugs Closed": bugsClosed,
      }
    }
  )

  const projectDemandsBurnupChartData = [
    {
      id: "Scope",
      data: project.weeklyProjectScopeUntilEnd.map((scope, index) => ({
        x: index,
        y: scope,
      })),
    },
    {
      id: "Ideal",
      data: project.currentWeeklyScopeIdealBurnup.map((idealScope, index) => ({
        x: index,
        y: idealScope,
      })),
    },
    {
      id: "Delivered",
      data: projectConsolidationsWeekly.map(({ projectThroughput }, index) => ({
        x: index,
        y: projectThroughput,
      })),
    },
  ]

  const projectHoursBurnupChartData = [
    {
      id: "Scope",
      data: project.weeklyProjectScopeHoursUntilEnd.map((scope, index) => ({
        x: index,
        y: scope,
      })),
    },
    {
      id: "Ideal",
      data: project.currentWeeklyHoursIdealBurnup.map((idealScope, index) => ({
        x: index,
        y: idealScope,
      })),
    },
    {
      id: "Delivered", //@todo normalize y - check this
      data: projectConsolidationsWeekly.map(
        ({ projectThroughputHours }, index) => ({
          x: index,
          y: projectThroughputHours,
        })
      ),
    },
  ]

  const leadTimeP80ChartData = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(({ leadTimeP80 }, index) => {
        const leadTimep80InDays = secondsToDays(leadTimeP80)

        return {
          x: index,
          y: leadTimep80InDays,
        }
      }),
    },
  ]

  //@todo
  const cumulativeFlowDiagramChartData = leadTimeP80ChartData

  const projectQualityChartData = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, projectQuality }) => {
          const qualityPercentage: string = (
            (1 - projectQuality) *
            100
          ).toFixed(2)

          return {
            x: consolidationDate,
            y: qualityPercentage,
          }
        }
      ),
    },
  ]

  const leadTimeControlChartData = [
    {
      id: "Lead Time",
      data: demandsFinishedWithLeadtime.map(
        ({ externalId, leadtime }, index) => {
          return {
            x: index,
            y: leadtime,
            label: externalId,
          }
        }
      ),
    },
  ]

  const leadTimeControlP65Marker = buildPercentileYAxisMarker({
    color: "#F80304",
    completionTime: Number(lastProjectConsolidationsWeekly?.leadTimeP65),
    legend: "Percentile 65", //@todo - put days with translation
  })

  const leadTimeControlP80Marker = buildPercentileYAxisMarker({
    color: "#daa520",
    completionTime: Number(lastProjectConsolidationsWeekly?.leadTimeP80),
    legend: "Percentile 80",
  })

  const leadTimeControlP95Marker = buildPercentileYAxisMarker({
    color: "#008000",
    completionTime: Number(lastProjectConsolidationsWeekly?.leadTimeP95),
    legend: "Percentile 95",
  })

  const projectQualityForCodingChartData = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, codeNeededBlocksCount }) => ({
          x: consolidationDate,
          y: codeNeededBlocksCount,
        })
      ),
    },
  ]

  const projectQualityForCodingPerDemand = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, codeNeededBlocksPerDemand }) => ({
          x: consolidationDate,
          y: codeNeededBlocksPerDemand,
        })
      ),
    },
  ]

  const flowEfficiencyChartData = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, flowEfficiency }) => ({
          x: consolidationDate,
          y: flowEfficiency,
        })
      ),
    },
  ]

  const hoursPerDemandChartData = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, hoursPerDemand }) => {
          return {
            x: consolidationDate,
            y: hoursPerDemand.toFixed(2),
          }
        }
      ),
    },
  ]

  const projectConsumedHoursByRoleChartData = projectConsolidationsWeekly.map(
    ({
      consolidationDate,
      projectThroughputHours,
      projectThroughputHoursManagement,
      projectThroughputHoursDevelopment,
      projectThroughputHoursDesign,
    }) => {
      return {
        period: consolidationDate,
        "Design Effort": projectThroughputHoursDesign,
        "Development Hour": projectThroughputHoursDevelopment,
        "Management Hour": projectThroughputHoursManagement,
        "Total Effort": projectThroughputHours,
      }
    }
  )

  const projectConsumedHoursByRoleInMonthChartData =
    projectConsolidationsLastMonth.map(
      ({
        consolidationDate,
        projectThroughputHoursInMonth,
        projectThroughputHoursManagementInMonth,
        projectThroughputHoursDevelopmentInMonth,
        projectThroughputHoursDesignInMonth,
      }) => {
        return {
          period: consolidationDate,
          "Design Effort in Month": projectThroughputHoursDesignInMonth,
          "Development Hour in Month": projectThroughputHoursDevelopmentInMonth,
          "Management Hour in Month": projectThroughputHoursManagementInMonth,
          "Total Effort in Month": projectThroughputHoursInMonth,
        }
      }
    )

  const projectHoursPerStage = hoursPerStageChartData.xAxis.map(
    (xValue, index) => {
      return {
        index: index,
        [xValue]: hoursPerStageChartData.yAxis[index],
      }
    }
  )

  return (
    <ProjectPage pageName={t("charts")} project={project}>
      <ProjectChartsTable project={project} demands={demands} />
      <Grid container spacing={2} sx={{ marginTop: "32px" }}>
        <ChartLineBox
          title={"Operational Math Risk Evolution"}
          data={operationalRiskChartData}
          axisLeftLegend={"Risk (%)"}
        />
        <ChartLineBox
          title={"Operational Math Risk Evolution - Team Data"}
          data={operationalTeamRiskChartData}
          axisLeftLegend={"Risk (%)"}
        />
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>Bugs</Typography>

            <BarChart
              data={projectBugsChartData}
              axisLeftLegend={"Bugs"}
              props={{
                groupMode: "grouped",
                keys: ["Bugs Openned", "Bugs Closed"],
                indexBy: "index",
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -37,
                },
              }}
            />
          </Box>
        </Grid>
        <ChartLineBox
          title={`Demands Burnup for ${project.name}`}
          data={projectDemandsBurnupChartData}
          axisLeftLegend={"Demands"}
        />
        <ChartLineBox
          title={`Hours Burnup for ${project.name}`}
          data={projectHoursBurnupChartData}
          axisLeftLegend={"Hours"}
        />
        <ChartLineBox
          title={"Lead Time (p80)"}
          data={leadTimeP80ChartData}
          axisLeftLegend={"Days"}
        />
        <ChartLineBox
          title={`Cumulative Flow Diagram for ${project.name}`}
          data={cumulativeFlowDiagramChartData}
          axisLeftLegend={"Demands"}
        />
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>Lead Time Control Chart</Typography>
            <ScatterChart
              data={leadTimeControlChartData}
              props={{
                markers: [
                  leadTimeControlP65Marker,
                  leadTimeControlP80Marker,
                  leadTimeControlP95Marker,
                ],
              }}
            />
          </Box>
        </Grid>
        <ChartLineBox
          title={"Quality: Bugs"}
          data={projectQualityChartData}
          axisLeftLegend={"Days"}
        />
        <ChartLineBox
          title={"Quality: Blocks for coding"}
          data={projectQualityForCodingChartData}
          axisLeftLegend={"Days"}
        />
        <ChartLineBox
          title={"Quality: Blocks for Coding per Demand"}
          data={projectQualityForCodingPerDemand}
          axisLeftLegend={"blocks per demand"}
        />
        <ChartLineBox
          title={"Flow Efficiency"}
          data={flowEfficiencyChartData}
          axisLeftLegend={"%"}
        />
        <ChartLineBox
          title={"Hours per Demand"}
          data={hoursPerDemandChartData}
          axisLeftLegend={"Hours"}
        />

        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>Consumed Hours by Role</Typography>

            <BarChart
              data={projectConsumedHoursByRoleChartData}
              axisLeftLegend={"Hours"}
              props={{
                groupMode: "grouped",
                keys: [
                  "Design Effort",
                  "Development Hour",
                  "Management Hour",
                  "Total Effort",
                ],
                indexBy: "period",
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -37,
                },
              }}
            />
          </Box>
        </Grid>

        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>Consumed Hours by Role in Month</Typography>

            <BarChart
              data={projectConsumedHoursByRoleInMonthChartData}
              axisLeftLegend={"Hours"}
              props={{
                groupMode: "grouped",
                keys: [
                  "Design Effort in Month",
                  "Development Hour in Month",
                  "Management Hour in Month",
                  "Total Effort in Month",
                ],
                indexBy: "period",
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -37,
                },
              }}
            />
          </Box>
        </Grid>
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>Hours Per Stage</Typography>

            <BarChart
              data={projectHoursPerStage}
              axisLeftLegend={"Hours"}
              props={{
                groupMode: "grouped",
                keys: hoursPerStageChartData.xAxis,
                indexBy: "index",
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -37,
                },
              }}
            />
          </Box>
        </Grid>
      </Grid>
    </ProjectPage>
  )
}

export default ProjectsChart
