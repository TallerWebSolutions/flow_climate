import { BarDatum } from "@nivo/bar"
import { SliceTooltipProps } from "@nivo/line"
import { useTranslation } from "react-i18next"

import { ChartGridItem } from "./charts/ChartGridItem"
import { BarChart } from "./charts/BarChart"
import { LineChart } from "./charts/LineChart"
import { normalizeCfdData } from "./charts/LineChart"
import { ScatterChart } from "./charts/ScatterChart"
import LineChartTooltip from "./charts/tooltips/LineChartTooltip"
import { secondsToDays } from "../lib/date"
import { ChartAxisData, Project } from "../modules/project/project.types"
import { Grid } from "@mui/material"

type ProjectDemandsChartsProps = {
  project: Project
  hoursPerCoordinationStageChartData?: ChartAxisData
}

const ProjectDemandsCharts = ({
  project,
  hoursPerCoordinationStageChartData,
}: ProjectDemandsChartsProps) => {
  const { t } = useTranslation(["projectChart"])
  const projectConsolidationsWeekly = project.projectConsolidationsWeekly
  const projectConsolidationsLastMonth = project.projectConsolidationsLastMonth
  const demandsFinishedWithLeadtime = project.demandsFinishedWithLeadtime
  const lastProjectConsolidationsWeekly =
    project.lastProjectConsolidationsWeekly
  const demandsFlowChartData = project.demandsFlowChartData
  const leadTimeHistogramData = project.leadTimeHistogramData
  const hoursPerStageChartData = project.hoursPerStageChartData
  const cumulativeFlowChartData = project.cumulativeFlowChartData

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
        [t("charts_tab.project_charts.bugs_openned")]: bugsOpened,
        [t("charts_tab.project_charts.bugs_closed")]: bugsClosed,
      }
    }
  )

  const cfdXaxis = cumulativeFlowChartData?.xAxis || []
  const cfdYaxis = cumulativeFlowChartData?.yAxis.reverse() || []
  const projectStages = cfdYaxis.map((item) => item.name)
  const projectCumulativeFlowChartData = projectStages?.map(
    (stage, stageIndex) => {
      return {
        id: stage,
        data: cfdXaxis.map((x, index) => {
          const currentStageY = cfdYaxis[stageIndex]?.data[index] || 0
          return {
            x,
            y: currentStageY,
          }
        }),
      }
    }
  )

  const committedChartData = demandsFlowChartData?.committedChartData
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
          [t("charts_tab.project_charts.flow_data_created")]:
            creationChartData[index],
          [t("charts_tab.project_charts.flow_data_committed_to")]:
            committedChartData[index],
          [t("charts_tab.project_charts.flow_data_pull_transactions")]:
            pullTransactionRate[index],
          [t("charts_tab.project_charts.flow_data_delivered")]:
            throughputChartData[index],
        }
      })
    : []

  const projectLeadTimeHistogramData: BarDatum[] = leadTimeHistogramData
    ? leadTimeHistogramData.keys.map((el, index) => {
        const projectLeadTimeHistogramDataKeysInDays =
          secondsToDays(el).toFixed(2)

        return {
          index,
          [t("charts_tab.project_charts.lead_time_histogram_chart_x_label")]:
            projectLeadTimeHistogramDataKeysInDays,
          [t("charts_tab.project_charts.lead_time_histogram_chart_y_label")]:
            leadTimeHistogramData.values[index],
        }
      })
    : []

  const projectDemandsBurnupChartData = [
    {
      id: t("charts_tab.project_charts.demands_burn_up_label_scope"),
      data: project.weeklyProjectScopeUntilEnd.map((scope, index) => ({
        x: index,
        y: scope,
      })),
    },
    {
      id: t("charts_tab.project_charts.demands_burn_up_label_ideal"),
      data: project.currentWeeklyScopeIdealBurnup.map((idealScope, index) => ({
        x: index,
        y: idealScope,
      })),
    },
    {
      id: t("charts_tab.project_charts.demands_burn_up_label_delivered"),
      data: projectConsolidationsWeekly.map(({ projectThroughput }, index) => ({
        x: index,
        y: projectThroughput,
      })),
    },
  ]

  const projectHoursBurnupChartData = [
    {
      id: t("charts_tab.project_charts.hours_burn_up_label_scope"),
      data: project.weeklyProjectScopeHoursUntilEnd.map((scope, index) => ({
        x: index,
        y: scope,
      })),
    },
    {
      id: t("charts_tab.project_charts.hours_burn_up_label_ideal"),
      data: project.currentWeeklyHoursIdealBurnup.map((idealScope, index) => ({
        x: index,
        y: idealScope,
      })),
    },
    {
      id: t("charts_tab.project_charts.hours_burn_up_label_delivered"),
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
          y: (1 - projectQuality) * 100,
        })
      ),
    },
  ]

  const leadTimeControlChartData = [
    {
      id: t("charts_tab.project_charts.lead_time_control_label"),
      data:
        demandsFinishedWithLeadtime?.map(({ externalId, leadtime }, index) => {
          const leadTimeInDays = secondsToDays(leadtime)

          return {
            x: index,
            y: leadTimeInDays,
            label: externalId,
          }
        }) || [],
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

  const leadTimeControlP65Marker = {
    value: leadTimeP65InDays,
    legend: t("charts_tab.project_charts.lead_time_control_marker_p65", {
      leadTime: leadTimeP65InDays,
    }),
  }

  const leadTimeControlP80Marker = {
    value: leadTimeP80InDays,
    legend: t("charts_tab.project_charts.lead_time_control_marker_p80", {
      leadTime: leadTimeP80InDays,
    }),
  }

  const leadTimeControlP95Marker = {
    value: leadTimeP95InDays,
    legend: t("charts_tab.project_charts.lead_time_control_marker_p95", {
      leadTime: leadTimeP95InDays,
    }),
  }

  const projectQualityForCodingChartData = [
    {
      id: project.name || "",
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
      id: project.name || "",
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
      id: project.name || "",
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, flowEfficiency }) => {
          const flowEfficiencyInPercentage = flowEfficiency / 100
          return {
            x: consolidationDate,
            y: flowEfficiencyInPercentage * 100,
          }
        }
      ),
    },
  ]

  const hoursPerDemandChartData = [
    {
      id: project.name || "",
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
      projectThroughputHoursAdditional,
      projectThroughputHoursUpstream,
      projectThroughputHoursDownstream,
    }) => {
      return {
        [t("charts_tab.project_charts.hours_consumed_x_label")]:
          consolidationDate,
        [t("charts_tab.project_charts.hours_consumed_upstream")]:
          projectThroughputHoursUpstream.toFixed(2),
        [t("charts_tab.project_charts.hours_consumed_downstream")]:
          projectThroughputHoursDownstream.toFixed(2),
        [t("charts_tab.project_charts.additional_hours_consumed")]:
          projectThroughputHoursAdditional?.toFixed(2) || 0,
        [t("charts_tab.project_charts.hours_consumed_total_throughput")]:
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
        [t("charts_tab.project_charts.consumed_hours_by_role_design_effort")]:
          projectThroughputHoursDesign.toFixed(2),
        [t(
          "charts_tab.project_charts.consumed_hours_by_role_development_effort"
        )]: projectThroughputHoursDevelopment.toFixed(2),
        [t(
          "charts_tab.project_charts.consumed_hours_by_role_management_effort"
        )]: projectThroughputHoursManagement.toFixed(2),
        [t("charts_tab.project_charts.consumed_hours_by_role_total_effort")]:
          projectThroughputHours.toFixed(2),
      }
    }
  )

  const projectConsumedHoursByRoleInMonthChartData =
    projectConsolidationsLastMonth?.map(
      ({
        consolidationDate,
        projectThroughputHoursInMonth,
        projectThroughputHoursManagementInMonth,
        projectThroughputHoursDevelopmentInMonth,
        projectThroughputHoursDesignInMonth,
      }) => {
        return {
          period: consolidationDate,
          [t(
            "charts_tab.project_charts.consumed_hours_by_role_in_month_design_effort"
          )]: projectThroughputHoursDesignInMonth.toFixed(2),
          [t(
            "charts_tab.project_charts.consumed_hours_by_role_in_month_development_effort"
          )]: projectThroughputHoursDevelopmentInMonth.toFixed(2),
          [t(
            "charts_tab.project_charts.consumed_hours_by_role_in_month_management_effort"
          )]: projectThroughputHoursManagementInMonth.toFixed(2),
          [t(
            "charts_tab.project_charts.consumed_hours_by_role_in_month_total_effort"
          )]: projectThroughputHoursInMonth.toFixed(2),
        }
      }
    ) || []

  const projectHoursPerStage = hoursPerStageChartData
    ? hoursPerStageChartData.xAxis.map((xValue, index: number) => {
        return {
          index: index,
          [xValue]: hoursPerStageChartData.yAxis[index],
        }
      })
    : []

  const projectHoursPerCoordinationStage = hoursPerCoordinationStageChartData
    ? hoursPerCoordinationStageChartData.xAxis.map((xValue, index: number) => {
        return {
          index: index,
          [xValue]: hoursPerCoordinationStageChartData.yAxis[index],
        }
      })
    : []

  const demandsCountByTeamMember = project.projectMembers.map((member) => ({
    [t("charts_tab.project_charts.demandsCount")]: member.demandsCount,
    name: member.memberName,
  }))

  return (
    <Grid container spacing={2} rowSpacing={8} sx={{ marginTop: 4 }}>
      <ChartGridItem
        title={t(
          "charts_tab.project_charts.operational_math_risk_evolution_chart"
        )}
      >
        <LineChart
          data={operationalRiskChartData}
          axisLeftLegend={`${t(
            "charts_tab.project_charts.operational_math_risk_evolution_y_label"
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
                  "charts_tab.project_charts.operational_math_risk_evolution_tooltip_label"
                )}
              />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t(
          "charts_tab.project_charts.operational_math_risk_evolution_team_data_chart"
        )}
      >
        <LineChart
          data={operationalTeamRiskChartData}
          axisLeftLegend={`${t(
            "charts_tab.project_charts.operational_math_risk_evolution_team_data_y_label"
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
                  "charts_tab.project_charts.operational_math_risk_evolution_team_data_tooltip_label"
                )}
              />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem title={t("charts_tab.project_charts.bugs_chart")}>
        <BarChart
          data={projectBugsChartData}
          axisLeftLegend={t("charts_tab.project_charts.bugs_y_label")}
          keys={[
            t("charts_tab.project_charts.bugs_openned"),
            t("charts_tab.project_charts.bugs_closed"),
          ]}
          indexBy="index"
        />
      </ChartGridItem>
      <ChartGridItem title={t("charts_tab.project_charts.flow_data_chart")}>
        <BarChart
          data={projectFlowChartData}
          keys={[
            t("charts_tab.project_charts.flow_data_created"),
            t("charts_tab.project_charts.flow_data_committed_to"),
            t("charts_tab.project_charts.flow_data_pull_transactions"),
            t("charts_tab.project_charts.flow_data_delivered"),
          ]}
          indexBy="index"
          axisLeftLegend={t("charts_tab.project_charts.flow_data_y_label")}
          axisBottomLegend={t("charts_tab.project_charts.flow_data_x_label")}
          groupMode="grouped"
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.demands_burn_up_chart", {
          projectName: project.name,
        })}
      >
        <LineChart
          data={projectDemandsBurnupChartData}
          axisLeftLegend={t(
            "charts_tab.project_charts.demands_burn_up_y_label"
          )}
          props={{
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.hours_burn_up_chart", {
          projectName: project.name,
        })}
      >
        <LineChart
          data={projectHoursBurnupChartData}
          axisLeftLegend={t("charts_tab.project_charts.hours_burn_up_y_label")}
          props={{
            yFormat: "=.2f",
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem title={t("charts_tab.project_charts.lead_time_p80_chart")}>
        <LineChart
          data={leadTimeP80ChartData}
          axisLeftLegend={t("charts_tab.project_charts.lead_time_p80_y_label")}
          props={{
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
          }}
        />
      </ChartGridItem>
      {projectCumulativeFlowChartData && (
        <ChartGridItem
          title={t("charts_tab.project_charts.cumulative_flow_chart", {
            projectName: project.name,
          })}
        >
          <LineChart
            data={normalizeCfdData(projectCumulativeFlowChartData)}
            axisLeftLegend={t(
              "charts_tab.project_charts.cumulative_flow_y_label"
            )}
            props={{
              yScale: {
                type: "linear",
                stacked: true,
              },
              areaOpacity: 1,
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
        </ChartGridItem>
      )}
      <ChartGridItem
        title={t("charts_tab.project_charts.lead_time_control_chart")}
      >
        <ScatterChart
          data={leadTimeControlChartData}
          markers={[
            leadTimeControlP65Marker,
            leadTimeControlP80Marker,
            leadTimeControlP95Marker,
          ]}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.lead_time_histogram_chart")}
      >
        <BarChart
          data={projectLeadTimeHistogramData}
          keys={[t("charts_tab.project_charts.lead_time_histogram_chart_hits")]}
          indexBy={t(
            "charts_tab.project_charts.lead_time_histogram_chart_x_label"
          )}
          axisLeftLegend={t(
            "charts_tab.project_charts.lead_time_histogram_chart_y_label"
          )}
          axisBottomLegend={t(
            "charts_tab.project_charts.lead_time_histogram_chart_x_label"
          )}
          padding={0}
        />
      </ChartGridItem>

      <ChartGridItem title={t("charts_tab.project_charts.quality_bugs_chart")}>
        <LineChart
          data={projectQualityChartData}
          axisLeftLegend="%"
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
                  "charts_tab.project_charts.quality_bugs_tooltip_label"
                )}
              />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.quality_bugs_for_coding_chart")}
      >
        <LineChart
          data={projectQualityForCodingChartData}
          axisLeftLegend={t(
            "charts_tab.project_charts.quality_bugs_for_coding_y_label"
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
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t(
                  "charts_tab.project_charts.quality_bugs_for_coding_tooltip_label"
                )}
              />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t(
          "charts_tab.project_charts.quality_bugs_for_coding_per_demand_chart"
        )}
      >
        <LineChart
          data={projectQualityForCodingPerDemand}
          axisLeftLegend={t(
            "charts_tab.project_charts.quality_bugs_for_coding_per_demand_y_label"
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
                  "charts_tab.project_charts.quality_bugs_for_coding_per_demand_tooltip_label"
                )}
              />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.flow_efficiency_chart")}
      >
        <LineChart
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
                xLabel={t(
                  "charts_tab.project_charts.flow_efficiency_tooltip_label"
                )}
              />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.hours_per_demand_chart")}
      >
        <LineChart
          data={hoursPerDemandChartData}
          axisLeftLegend={t(
            "charts_tab.project_charts.hours_per_demand_y_label"
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
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t(
                  "charts_tab.project_charts.hours_per_demand_tooltip_label"
                )}
              />
            ),
          }}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.hours_consumed_chart")}
      >
        <BarChart
          data={projectHoursConsummed}
          keys={[
            t("charts_tab.project_charts.hours_consumed_upstream"),
            t("charts_tab.project_charts.hours_consumed_downstream"),
            t("charts_tab.project_charts.additional_hours_consumed"),
            t("charts_tab.project_charts.hours_consumed_total_throughput"),
          ]}
          indexBy={t("charts_tab.project_charts.hours_consumed_x_label")}
          axisLeftLegend={t("charts_tab.project_charts.hours_consumed_y_label")}
          axisBottomLegend={t(
            "charts_tab.project_charts.hours_consumed_x_label"
          )}
          groupMode="grouped"
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.consumed_hours_by_role_chart")}
      >
        <BarChart
          data={projectConsumedHoursByRoleChartData}
          keys={[
            t("charts_tab.project_charts.consumed_hours_by_role_design_effort"),
            t(
              "charts_tab.project_charts.consumed_hours_by_role_development_effort"
            ),
            t(
              "charts_tab.project_charts.consumed_hours_by_role_management_effort"
            ),
            t("charts_tab.project_charts.consumed_hours_by_role_total_effort"),
          ]}
          indexBy="period"
          axisLeftLegend={t(
            "charts_tab.project_charts.consumed_hours_by_role_y_label"
          )}
          groupMode="grouped"
        />
      </ChartGridItem>
      <ChartGridItem
        title={t(
          "charts_tab.project_charts.consumed_hours_by_role_in_month_chart"
        )}
      >
        <BarChart
          data={projectConsumedHoursByRoleInMonthChartData}
          axisLeftLegend={t(
            "charts_tab.project_charts.consumed_hours_by_role_in_month_y_label"
          )}
          keys={[
            t(
              "charts_tab.project_charts.consumed_hours_by_role_in_month_design_effort"
            ),
            t(
              "charts_tab.project_charts.consumed_hours_by_role_in_month_development_effort"
            ),
            t(
              "charts_tab.project_charts.consumed_hours_by_role_in_month_management_effort"
            ),
            t(
              "charts_tab.project_charts.consumed_hours_by_role_in_month_total_effort"
            ),
          ]}
          indexBy="period"
          groupMode="grouped"
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.hours_per_stage_chart")}
      >
        <BarChart
          data={projectHoursPerStage}
          keys={hoursPerStageChartData?.xAxis.map(String) || []}
          indexBy="index"
          axisLeftLegend={t(
            "charts_tab.project_charts.hours_per_stage_y_label"
          )}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t(
          "charts_tab.project_charts.hours_per_coordination_stage_chart"
        )}
      >
        <BarChart
          data={projectHoursPerCoordinationStage}
          keys={hoursPerCoordinationStageChartData?.xAxis.map(String) || []}
          indexBy="index"
          axisLeftLegend={t(
            "charts_tab.project_charts.hours_per_coordination_stage_y_label"
          )}
        />
      </ChartGridItem>
      <ChartGridItem
        title={t("charts_tab.project_charts.demandsCountByTeamMember")}
      >
        <BarChart
          data={demandsCountByTeamMember}
          indexBy="name"
          keys={[t("charts_tab.project_charts.demandsCount")]}
        />
      </ChartGridItem>
    </Grid>
  )
}

export default ProjectDemandsCharts