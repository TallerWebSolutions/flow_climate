import { useQuery, gql } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { ProjectPage } from "../../components/ProjectPage"
import { BarChart } from "../../components/charts/BarChart"
import { TasksChartsDTO } from "../Tasks/TasksCharts"
import BarChartTooltip, {
  BarData,
} from "../../components/charts/tooltips/BarChartTooltip"
import { Grid, Typography } from "@mui/material"
import { useParams } from "react-router-dom"
import ChartLineBox from "../../components/charts/ChartLineBox"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../components/charts/tooltips/LineChartTooltip"
import { TasksCharts } from "../Tasks/List"
import { BarDatum } from "@nivo/bar"
import { secondsToDays } from "../../lib/date"
import { keyValueToAxisData } from "../../lib/charts"
import { ScatterChart } from "../../components/charts/ScatterChart"
import { ChartBox } from "../../components/charts/ChartBox"

const PROJECT_TASKS_CHARTS_QUERY = gql`
  query ProjectDemandsCharts($TasksProjectId: ID, $ID: Int!) {
    tasksList(projectId: $TasksProjectId) {
      tasksCharts {
        xAxis
        creation: creationArray
        throughput: throughputArray
      }
      deliveredLeadTimeP65
      deliveredLeadTimeP80
      deliveredLeadTimeP95
      completiontimeHistogramChartData {
        keys
        values
      }
    }
    project(id: $ID) {
      tasksBurnup {
        projectTasksIdeal
        projectTasksScope
        projectTasksThroughtput
        xAxis
      }
      projectConsolidationsWeekly {
        consolidationDate
        tasksBasedOperationalRisk
      }
    }
  }
`

const ProjectTasksCharts = () => {
  const { t } = useTranslation(["tasks"])
  const { projectId } = useParams()
  const { data, loading } = useQuery<TasksChartsDTO>(
    PROJECT_TASKS_CHARTS_QUERY,
    {
      variables: {
        TasksProjectId: Number(projectId),
        ID: Number(projectId),
      },
    }
  )

  const taskList = data?.tasksList
  const project = data?.project
  const tasksBurnup = project?.tasksBurnup
  const flowChartGroupNames: (keyof TasksCharts)[] = ["creation", "throughput"]
  const flowChartData: BarDatum[] =
    taskList?.tasksCharts.xAxis.map((key, indexAxis) => {
      const group: BarDatum = { key }
      flowChartGroupNames.forEach((name) => {
        const value = Number(taskList.tasksCharts[name][indexAxis]) || ""
        group[name] = value
      })
      return group
    }) || []

  const projectTasksBurnupChartData = tasksBurnup
    ? [
        {
          id: t("charts.scope"),
          data: tasksBurnup.projectTasksScope.map((scope, index) => ({
            x: tasksBurnup.xAxis[index],
            y: scope,
          })),
        },
        {
          id: t("charts.ideal"),
          data: tasksBurnup.projectTasksIdeal.map((idealScope, index) => ({
            x: tasksBurnup.xAxis[index],
            y: idealScope.toFixed(2),
          })),
        },
        {
          id: t("charts.delivered"),
          data: tasksBurnup.projectTasksThroughtput.map(
            (throughtput, index) => ({
              x: tasksBurnup.xAxis[index],
              y: throughtput,
            })
          ),
        },
      ]
    : []
  const projectConsolidationsWeekly = project?.projectConsolidationsWeekly || []

  const operationalRiskChartData = [
    {
      id: "Operational Math Risk Evolution",
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, tasksBasedOperationalRisk }) => ({
          x: consolidationDate,
          y: tasksBasedOperationalRisk,
        })
      ),
    },
  ]

  const deliveredLeadTimeP65 = secondsToDays(
    Number(taskList?.deliveredLeadTimeP65)
  )
  const deliveredLeadTimeP80 = secondsToDays(
    Number(taskList?.deliveredLeadTimeP80)
  )
  const deliveredLeadTimeP95 = secondsToDays(
    Number(taskList?.deliveredLeadTimeP95)
  )

  const deliveredLeadTimeP65Marker = {
    value: deliveredLeadTimeP65,
    legend: t("charts.control_completion_time_p65_marker", {
      days: deliveredLeadTimeP65,
    }),
  }

  const deliveredLeadTimeP80Marker = {
    value: deliveredLeadTimeP80,
    legend: t("charts.control_completion_time_p80_marker", {
      days: deliveredLeadTimeP80,
    }),
  }

  const deliveredLeadTimeP95Marker = {
    value: deliveredLeadTimeP95,
    legend: t("charts.control_completion_time_p95_marker", {
      days: deliveredLeadTimeP95,
    }),
  }

  const completionTimeChartData = {
    keys:
      taskList?.completiontimeHistogramChartData.keys.map(secondsToDays) || [],
    values: taskList?.completiontimeHistogramChartData.values || [],
  }

  return (
    <ProjectPage pageName="" loading={loading} dashboard>
      <Grid container spacing={2} rowSpacing={8} sx={{ marginTop: 4 }}>
        <Grid item xs={6} sx={{ padding: 1 }}>
          <Typography>{t("charts.flow_chart_data")}</Typography>
          <BarChart
            axisLeftLegend={t("charts.tasks")}
            data={flowChartData}
            keys={flowChartGroupNames}
            axisBottomLegend={t("charts.flow_data_period_legend")}
            indexBy="key"
            groupMode="grouped"
            tooltip={(data: BarData) => {
              return (
                <BarChartTooltip
                  xLabel={t("charts.flow_data_tooltip_x_legend")}
                  data={data}
                />
              )
            }}
          />
        </Grid>

        <ChartLineBox
          title={t("charts.burnup_chart_data")}
          data={projectTasksBurnupChartData}
          axisLeftLegend={t("charts.tasks")}
          props={{
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip slice={slice} />
            ),
          }}
        />

        <ChartLineBox
          title={t("charts.operational_math_risk_evolution_chart")}
          data={operationalRiskChartData}
          axisLeftLegend={`${t(
            "charts.operational_math_risk_evolution_y_label"
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
                  "charts.operational_math_risk_evolution_tooltip_label"
                )}
              />
            ),
          }}
        />
        <Grid item xs={6} sx={{ padding: 1 }}>
          {completionTimeChartData && (
            <ChartBox title={t("charts.control_completion_time_title")}>
              <ScatterChart
                axisLeftLegend={t("charts.days")}
                data={keyValueToAxisData(completionTimeChartData)}
                markers={[
                  deliveredLeadTimeP65Marker,
                  deliveredLeadTimeP80Marker,
                  deliveredLeadTimeP95Marker,
                ]}
              />
            </ChartBox>
          )}
        </Grid>
      </Grid>
    </ProjectPage>
  )
}

export default ProjectTasksCharts
