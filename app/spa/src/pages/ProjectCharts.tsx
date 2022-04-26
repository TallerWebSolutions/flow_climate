import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  Box,
  CircularProgress,
  Grid,
  Typography,
} from "@mui/material"
import { BarDatum } from "@nivo/bar"
import { SliceTooltipProps } from "@nivo/line"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { BarChart } from "../components/charts/BarChart"
import { LineChart, LineGraphProps } from "../components/charts/LineChart"
import { ScatterChart } from "../components/charts/ScatterChart"
import LineChartTooltip from "../components/charts/tooltips/LineChartTooltip"
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

        <LineChart data={data} axisLeftLegend={axisLeftLegend} props={props} />
      </Box>
    </Grid>
  )
}

const ProjectCharts = () => {
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
        ({ consolidationDate, operationalRisk }) => ({
          x: consolidationDate,
          y: operationalRisk,
        })
      ),
    },
  ]

  const operationalTeamRiskChartData = [
    {
      id: "Operational Risk (%)",
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, tasksBasedOperationalRisk }) => ({
          x: consolidationDate,
          y: tasksBasedOperationalRisk,
        })
      ),
    },
  ]

  const projectBugsChartData: BarDatum[] = projectConsolidationsWeekly.map(
    ({ bugsOpened, bugsClosed }, index) => {
      return {
        index: index,
        [t("project_charts.bugs_openned")]: bugsOpened,
        [t("project_charts.bugs_closed")]: bugsClosed,
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
      id: "Delivered",
      data: projectConsolidationsWeekly.map(
        ({ projectThroughputHours }, index) => ({
          x: index,
          y: projectThroughputHours.toFixed(2),
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
        ({ consolidationDate, flowEfficiency }) => {
          const flowEfficiencyInPercentage = flowEfficiency / 100
          return {
            x: consolidationDate,
            y: flowEfficiencyInPercentage,
          }
        }
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
        "Design Effort": projectThroughputHoursDesign.toFixed(2),
        "Development Hour": projectThroughputHoursDevelopment.toFixed(2),
        "Management Hour": projectThroughputHoursManagement.toFixed(2),
        "Total Effort": projectThroughputHours.toFixed(2),
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
          "Design Effort": projectThroughputHoursDesignInMonth.toFixed(2),
          "Development Hour":
            projectThroughputHoursDevelopmentInMonth.toFixed(2),
          "Management Hour": projectThroughputHoursManagementInMonth.toFixed(2),
          "Total Effort": projectThroughputHoursInMonth.toFixed(2),
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

      <Grid container spacing={2} rowSpacing={8} sx={{ marginTop: "32px" }}>
        <ChartLineBox
          title={t("project_charts.operational_math_risk_evolution_chart")}
          data={operationalRiskChartData}
          axisLeftLegend={`${t(
            "project_charts.operational_math_risk_evolution_y_label"
          )} (%)`}
          props={{
            margin: { left: 80, right: 20, top: 25, bottom: 65 },
            axisBottom: {
              tickSize: 5,
              tickPadding: 5,
              legendPosition: "middle",
              legendOffset: 60,
              tickRotation: -40,
            },
            yFormat: "=.2%",
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t(
                  "project_charts.operational_math_risk_evolution_tooltip_label"
                )}
              />
            ),
          }}
        />
        <ChartLineBox
          title={t(
            "project_charts.operational_math_risk_evolution_team_data_chart"
          )}
          data={operationalTeamRiskChartData}
          axisLeftLegend={`${t(
            "project_charts.operational_math_risk_evolution_team_data_y_label"
          )} (%)`}
          props={{
            margin: { left: 80, right: 20, top: 25, bottom: 65 },
            axisBottom: {
              tickSize: 5,
              tickPadding: 5,
              legendPosition: "middle",
              legendOffset: 60,
              tickRotation: -40,
            },
            yFormat: "=.2%",
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t(
                  "project_charts.operational_math_risk_evolution_team_data_tooltip_label"
                )}
              />
            ),
          }}
        />
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>{t("project_charts.bugs_chart")}</Typography>

            <BarChart
              data={projectBugsChartData}
              axisLeftLegend={t("project_charts.bugs_y_label")}
              props={{
                groupMode: "grouped",
                keys: [
                  t("project_charts.bugs_openned"),
                  t("project_charts.bugs_closed"),
                ],
                indexBy: "index",
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: 0,
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
          title={t("project_charts.flow_efficiency_chart")}
          data={flowEfficiencyChartData}
          axisLeftLegend={"%"}
          props={{
            margin: { left: 80, right: 20, top: 25, bottom: 65 },
            axisBottom: {
              tickSize: 5,
              tickPadding: 5,
              legendPosition: "middle",
              legendOffset: 60,
              tickRotation: -40,
            },
            yFormat: "=.2%",
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t("project_charts.flow_efficiency_tooltip_label")}
              />
            ),
          }}
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
                  tickRotation: -40,
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
                  tickRotation: -40,
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
                  tickRotation: -40,
                },
              }}
            />
          </Box>
        </Grid>
      </Grid>
    </ProjectPage>
  )
}

export default ProjectCharts
