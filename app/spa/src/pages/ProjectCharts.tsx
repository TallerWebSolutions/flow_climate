import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  Box,
  CircularProgress,
  Grid,
  Typography,
} from "@mui/material"
import { BarDatum } from "@nivo/bar"
import { Serie, SliceTooltipProps } from "@nivo/line"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { BarChart } from "../components/charts/BarChart"
import { LineChart, LineGraphProps } from "../components/charts/LineChart"
import { ScatterChart } from "../components/charts/ScatterChart"
import LineChartTooltip from "../components/charts/tooltips/LineChartTooltip"
import ScatterChartTooltip, {
  ScatterNode,
} from "../components/charts/tooltips/ScatterChartTooltip"
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

const PROJECT_CHART_QUERY = gql`
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

      leadTimeHistogramData {
        keys
        values
      }

      demandsFlowChartData {
        creationChartData
        committedChartData
        pullTransactionRate
        throughputChartData
      }

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
        projectThroughputHoursUpstream
        projectThroughputHoursDownstream
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

      cumulativeFlowChartData {
        xAxis
        yAxis {
          name
          data
        }
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
  const { t, i18n } = useTranslation(["projectChart"])
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
  const demandsFlowChartData = project?.demandsFlowChartData
  const leadTimeHistogramData = project?.leadTimeHistogramData
  const hoursPerStageChartData = project?.hoursPerStageChartData
  const cumulativeFlowChartData = project?.cumulativeFlowChartData
  const demands = data?.demands!
  const isLanguagePT = i18n.language === "pt-BR"

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

  const projectCumulativeFlowChartDataYAxis = cumulativeFlowChartData?.yAxis
  const projectCumulativeFlowChartData: Serie[] =
    Array.isArray(projectCumulativeFlowChartDataYAxis) &&
    projectCumulativeFlowChartDataYAxis.length > 0 &&
    cumulativeFlowChartData
      ? cumulativeFlowChartData?.xAxis.map((_, index) => {
          const yAxis = cumulativeFlowChartData.yAxis

          if (yAxis[index]?.name || yAxis[index]?.data === undefined) {
            return {
              id: "",
              data: [],
            }
          }

          return {
            id: yAxis[index].name,
            data: yAxis[index].data.map((cumulativeValue, index) => ({
              x: cumulativeFlowChartData?.xAxis[index],
              y: cumulativeValue,
            })),
          }
        })
      : []

  const committedChartData = demandsFlowChartData.committedChartData
  const projectFlowChartData: BarDatum[] = committedChartData
    ? committedChartData?.map((_, index) => {
        const creationChartData = demandsFlowChartData.creationChartData
          ? demandsFlowChartData.creationChartData
          : []

        const pullTransactionRate = demandsFlowChartData.pullTransactionRate
          ? demandsFlowChartData.pullTransactionRate
          : []

        const throughputChartData = demandsFlowChartData.throughputChartData
          ? demandsFlowChartData.throughputChartData
          : []

        return {
          index,
          [t("project_charts.flow_data_created")]: creationChartData[index],
          [t("project_charts.flow_data_committed_to")]:
            committedChartData[index],
          [t("project_charts.flow_data_pull_transactions")]:
            pullTransactionRate[index],
          [t("project_charts.flow_data_delivered")]: throughputChartData[index],
        }
      })
    : []

  const projectLeadTimeHistogramData: BarDatum[] =
    leadTimeHistogramData.keys.map((el, index) => {
      const projectLeadTimeHistogramDataKeysInDays =
        secondsToDays(el).toFixed(2)

      return {
        index,
        [t("project_charts.lead_time_histogram_chart_x_label")]:
          projectLeadTimeHistogramDataKeysInDays,
        [t("project_charts.lead_time_histogram_chart_y_label")]:
          leadTimeHistogramData.values[index],
      }
    })

  const projectDemandsBurnupChartData = [
    {
      id: t("project_charts.demands_burn_up_label_scope"),
      data: project.weeklyProjectScopeUntilEnd.map((scope, index) => ({
        x: index,
        y: scope,
      })),
    },
    {
      id: t("project_charts.demands_burn_up_label_ideal"),
      data: project.currentWeeklyScopeIdealBurnup.map((idealScope, index) => ({
        x: index,
        y: idealScope,
      })),
    },
    {
      id: t("project_charts.demands_burn_up_label_delivered"),
      data: projectConsolidationsWeekly.map(({ projectThroughput }, index) => ({
        x: index,
        y: projectThroughput,
      })),
    },
  ]

  const projectHoursBurnupChartData = [
    {
      id: t("project_charts.hours_burn_up_label_scope"),
      data: project.weeklyProjectScopeHoursUntilEnd.map((scope, index) => ({
        x: index,
        y: scope,
      })),
    },
    {
      id: t("project_charts.hours_burn_up_label_ideal"),
      data: project.currentWeeklyHoursIdealBurnup.map((idealScope, index) => ({
        x: index,
        y: idealScope,
      })),
    },
    {
      id: t("project_charts.hours_burn_up_label_delivered"),
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
        ({ consolidationDate, projectQuality }) => ({
          x: consolidationDate,
          y: 1 - projectQuality,
        })
      ),
    },
  ]

  const leadTimeControlChartData = [
    {
      id: t("project_charts.lead_time_control_label"),
      data: demandsFinishedWithLeadtime.map(
        ({ externalId, leadtime }, index) => {
          const leadTimeInDays = secondsToDays(leadtime)

          return {
            x: index,
            y: leadTimeInDays,
            label: externalId,
          }
        }
      ),
    },
  ]

  const leadTimeP65InDays = secondsToDays(
    Number(lastProjectConsolidationsWeekly?.leadTimeP65)
  )
  const leadTimeP80InDays = secondsToDays(
    Number(lastProjectConsolidationsWeekly?.leadTimeP80)
  )
  const leadTimeP95InDays = secondsToDays(
    Number(lastProjectConsolidationsWeekly?.leadTimeP95)
  )

  const leadTimeControlP65Marker = buildPercentileYAxisMarker({
    color: "#F80304",
    completionTime: leadTimeP65InDays,
    legend: t("project_charts.lead_time_control_marker_p65", {
      leadTime: leadTimeP65InDays,
    }),
  })

  const leadTimeControlP80Marker = buildPercentileYAxisMarker({
    color: "#daa520",
    completionTime: leadTimeP80InDays,
    legend: t("project_charts.lead_time_control_marker_p80", {
      leadTime: leadTimeP80InDays,
    }),
  })

  const leadTimeControlP95Marker = buildPercentileYAxisMarker({
    color: "#008000",
    completionTime: leadTimeP95InDays,
    legend: t("project_charts.lead_time_control_marker_p95", {
      leadTime: leadTimeP95InDays,
    }),
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

  const projectHoursConsummed = projectConsolidationsWeekly.map(
    ({
      consolidationDate,
      projectThroughputHours,
      projectThroughputHoursUpstream,
      projectThroughputHoursDownstream,
    }) => {
      return {
        [t("project_charts.hours_consumed_x_label")]: consolidationDate,
        [t("project_charts.hours_consumed_upstream")]:
          projectThroughputHoursUpstream.toFixed(2),
        [t("project_charts.hours_consumed_downstream")]:
          projectThroughputHoursDownstream.toFixed(2),
        [t("project_charts.hours_consumed_total_throughput")]:
          projectThroughputHours.toFixed(2),
      }
    }
  )

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
        [t("project_charts.consumed_hours_by_role_design_effort")]:
          projectThroughputHoursDesign.toFixed(2),
        [t("project_charts.consumed_hours_by_role_development_effort")]:
          projectThroughputHoursDevelopment.toFixed(2),
        [t("project_charts.consumed_hours_by_role_management_effort")]:
          projectThroughputHoursManagement.toFixed(2),
        [t("project_charts.consumed_hours_by_role_total_effort")]:
          projectThroughputHours.toFixed(2),
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
          [t("project_charts.consumed_hours_by_role_in_month_design_effort")]:
            projectThroughputHoursDesignInMonth.toFixed(2),
          [t(
            "project_charts.consumed_hours_by_role_in_month_development_effort"
          )]: projectThroughputHoursDevelopmentInMonth.toFixed(2),
          [t(
            "project_charts.consumed_hours_by_role_in_month_management_effort"
          )]: projectThroughputHoursManagementInMonth.toFixed(2),
          [t("project_charts.consumed_hours_by_role_in_month_total_effort")]:
            projectThroughputHoursInMonth.toFixed(2),
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
    <ProjectPage pageName={t("charts")}>
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
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>{t("project_charts.flow_data_chart")}</Typography>

            <BarChart
              data={projectFlowChartData}
              props={{
                groupMode: "grouped",
                keys: [
                  t("project_charts.flow_data_created"),
                  t("project_charts.flow_data_committed_to"),
                  t("project_charts.flow_data_pull_transactions"),
                  t("project_charts.flow_data_delivered"),
                ],
                indexBy: "index",
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisLeft: {
                  tickSize: 5,
                  tickPadding: 5,
                  tickRotation: 0,
                  legend: t("project_charts.flow_data_y_label"),
                  legendPosition: "middle",
                  legendOffset: -55,
                },
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legend: t("project_charts.flow_data_x_label"),
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -40,
                },
              }}
            />
          </Box>
        </Grid>

        <ChartLineBox
          title={t("project_charts.demands_burn_up_chart", {
            projectName: project.name,
          })}
          data={projectDemandsBurnupChartData}
          axisLeftLegend={t("project_charts.demands_burn_up_y_label")}
          props={{
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
          }}
        />

        <ChartLineBox
          title={t("project_charts.hours_burn_up_chart", {
            projectName: project.name,
          })}
          data={projectHoursBurnupChartData}
          axisLeftLegend={t("project_charts.hours_burn_up_y_label")}
          props={{
            yFormat: "=.2f",
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
          }}
        />
        <ChartLineBox
          title={t("project_charts.lead_time_p80_chart")}
          data={leadTimeP80ChartData}
          axisLeftLegend={t("project_charts.lead_time_p80_y_label")}
          props={{
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
          }}
        />
        <ChartLineBox
          title={t("project_charts.cumulative_flow_chart", {
            projectName: project.name,
          })}
          data={projectCumulativeFlowChartData}
          axisLeftLegend={t("project_charts.cumulative_flow_y_label")}
          props={{
            enableArea: true,
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
            margin: { left: 80, right: 20, top: 25, bottom: 65 },
            axisBottom: {
              tickSize: 5,
              tickPadding: 5,
              legendPosition: "middle",
              legendOffset: 60,
              tickRotation: -40,
            },
          }}
        />
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>
              {t("project_charts.lead_time_control_chart")}
            </Typography>
            <ScatterChart
              data={leadTimeControlChartData}
              props={{
                markers: [
                  leadTimeControlP65Marker,
                  leadTimeControlP80Marker,
                  leadTimeControlP95Marker,
                ],
                tooltip: (data: { node: ScatterNode }) => {
                  const demandExternalID = data.node.data.label

                  return (
                    <ScatterChartTooltip
                      xLabel={t(
                        "project_charts.lead_time_control_tooltip_label"
                      )}
                      customXValue={demandExternalID}
                      node={data.node}
                    />
                  )
                },
              }}
            />
          </Box>
        </Grid>

        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>
              {t("project_charts.lead_time_histogram_chart")}
            </Typography>

            <BarChart
              data={projectLeadTimeHistogramData}
              props={{
                groupMode: "grouped",
                keys: [t("project_charts.lead_time_histogram_chart_hits")],
                indexBy: t("project_charts.lead_time_histogram_chart_x_label"),
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisLeft: {
                  tickSize: 5,
                  tickPadding: 5,
                  tickRotation: 0,
                  legend: t("project_charts.lead_time_histogram_chart_y_label"),
                  legendPosition: "middle",
                  legendOffset: -55,
                },
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legend: t("project_charts.lead_time_histogram_chart_x_label"),
                  legendPosition: "middle",
                  legendOffset: 60,
                },
              }}
            />
          </Box>
        </Grid>

        <ChartLineBox
          title={t("project_charts.quality_bugs_chart")}
          data={projectQualityChartData}
          axisLeftLegend={t("project_charts.quality_bugs_y_label")}
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
                xLabel={t("project_charts.quality_bugs_tooltip_label")}
              />
            ),
          }}
        />
        <ChartLineBox
          title={t("project_charts.quality_bugs_for_coding_chart")}
          data={projectQualityForCodingChartData}
          axisLeftLegend={t("project_charts.quality_bugs_for_coding_y_label")}
          props={{
            margin: { left: 80, right: 20, top: 25, bottom: 65 },
            axisBottom: {
              tickSize: 5,
              tickPadding: 5,
              legendPosition: "middle",
              legendOffset: 60,
              tickRotation: -40,
            },
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t(
                  "project_charts.quality_bugs_for_coding_tooltip_label"
                )}
              />
            ),
          }}
        />
        <ChartLineBox
          title={t("project_charts.quality_bugs_for_coding_per_demand_chart")}
          data={projectQualityForCodingPerDemand}
          axisLeftLegend={t(
            "project_charts.quality_bugs_for_coding_per_demand_y_label"
          )}
          props={{
            margin: { left: 80, right: 20, top: 25, bottom: 65 },
            axisBottom: {
              tickSize: 5,
              tickPadding: 5,
              legendPosition: "middle",
              legendOffset: 60,
              tickRotation: -40,
            },
            enableSlices: "x",
            yFormat: "=.2f",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t(
                  "project_charts.quality_bugs_for_coding_per_demand_tooltip_label"
                )}
              />
            ),
          }}
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
          title={t("project_charts.hours_per_demand_chart")}
          data={hoursPerDemandChartData}
          axisLeftLegend={t("project_charts.hours_per_demand_y_label")}
          props={{
            margin: { left: 80, right: 20, top: 25, bottom: 65 },
            axisBottom: {
              tickSize: 5,
              tickPadding: 5,
              legendPosition: "middle",
              legendOffset: 60,
              tickRotation: -40,
            },
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t("project_charts.hours_per_demand_tooltip_label")}
              />
            ),
          }}
        />
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>{t("project_charts.hours_consumed_chart")}</Typography>

            <BarChart
              data={projectHoursConsummed}
              props={{
                groupMode: "grouped",
                keys: [
                  t("project_charts.hours_consumed_upstream"),
                  t("project_charts.hours_consumed_downstream"),
                  t("project_charts.hours_consumed_total_throughput"),
                ],
                indexBy: t("project_charts.hours_consumed_x_label"),
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisLeft: {
                  tickSize: 5,
                  tickPadding: 5,
                  tickRotation: 0,
                  legend: t("project_charts.hours_consumed_y_label"),
                  legendPosition: "middle",
                  legendOffset: -55,
                },
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legend: t("project_charts.hours_consumed_x_label"),
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
            <Typography>
              {t("project_charts.consumed_hours_by_role_chart")}
            </Typography>

            <BarChart
              data={projectConsumedHoursByRoleChartData}
              props={{
                groupMode: "grouped",
                keys: [
                  t("project_charts.consumed_hours_by_role_design_effort"),
                  t("project_charts.consumed_hours_by_role_development_effort"),
                  t("project_charts.consumed_hours_by_role_management_effort"),
                  t("project_charts.consumed_hours_by_role_total_effort"),
                ],
                indexBy: "period",
                margin: { top: 50, right: 60, bottom: 65, left: 60 },
                padding: 0.3,
                axisLeft: {
                  tickSize: 5,
                  tickPadding: 5,
                  tickRotation: 0,
                  legend: t("project_charts.consumed_hours_by_role_y_label"),
                  legendPosition: "middle",
                  legendOffset: -55,
                },
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -40,
                },
                legends: [
                  {
                    dataFrom: "keys",
                    anchor: isLanguagePT ? "top-left" : "top",
                    direction: isLanguagePT ? "column" : "row",
                    toggleSerie: true,
                    justify: false,
                    translateX: 0,
                    translateY: -25,
                    itemsSpacing: 0,
                    itemDirection: "left-to-right",
                    itemWidth: 125,
                    itemHeight: 20,
                    itemOpacity: 0.75,
                    symbolSize: 12,
                    symbolShape: "circle",
                    symbolBorderColor: "rgba(0, 0, 0, .5)",
                    effects: [
                      {
                        on: "hover",
                        style: {
                          itemBackground: "rgba(0, 0, 0, .03)",
                          itemOpacity: 1,
                        },
                      },
                    ],
                  },
                ],
              }}
            />
          </Box>
        </Grid>
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>
              {t("project_charts.consumed_hours_by_role_in_month_chart")}
            </Typography>
            <BarChart
              data={projectConsumedHoursByRoleInMonthChartData}
              axisLeftLegend={t(
                "project_charts.consumed_hours_by_role_in_month_y_label"
              )}
              props={{
                groupMode: "grouped",
                keys: [
                  t(
                    "project_charts.consumed_hours_by_role_in_month_design_effort"
                  ),
                  t(
                    "project_charts.consumed_hours_by_role_in_month_development_effort"
                  ),
                  t(
                    "project_charts.consumed_hours_by_role_in_month_management_effort"
                  ),
                  t(
                    "project_charts.consumed_hours_by_role_in_month_total_effort"
                  ),
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
                legends: [
                  {
                    dataFrom: "keys",
                    anchor: isLanguagePT ? "top-left" : "top",
                    direction: isLanguagePT ? "column" : "row",
                    toggleSerie: true,
                    justify: false,
                    translateX: 0,
                    translateY: -25,
                    itemsSpacing: 0,
                    itemDirection: "left-to-right",
                    itemWidth: 125,
                    itemHeight: 20,
                    itemOpacity: 0.75,
                    symbolSize: 12,
                    symbolShape: "circle",
                    symbolBorderColor: "rgba(0, 0, 0, .5)",
                    effects: [
                      {
                        on: "hover",
                        style: {
                          itemBackground: "rgba(0, 0, 0, .03)",
                          itemOpacity: 1,
                        },
                      },
                    ],
                  },
                ],
              }}
            />
          </Box>
        </Grid>
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>{t("project_charts.hours_per_stage_chart")}</Typography>

            <BarChart
              data={projectHoursPerStage}
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
                axisLeft: {
                  tickSize: 5,
                  tickPadding: 5,
                  tickRotation: 0,
                  legend: t("project_charts.hours_per_stage_y_label"),
                  legendPosition: "middle",
                  legendOffset: -55,
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
