import { BarDatum } from "@nivo/bar"
import { useQuery, gql } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { ProjectPage } from "../../components/ProjectPage"
import { BarChart } from "../../components/charts/BarChart"
import { TasksCharts } from "../Tasks/List"
import { TasksChartsDTO } from "../Tasks/TasksCharts"
import BarChartTooltip, {
  BarData,
} from "../../components/charts/tooltips/BarChartTooltip"
import { Grid, Typography } from "@mui/material"

const PROJECT_TASKS_CHARTS_QUERY = gql`
  query ProjectTasksCharts($projectId: ID) {
    tasksList(projectId: $projectId) {
      tasksCharts {
        xAxis
        creation: creationArray
        throughput: throughputArray
      }
    }
  }
`

const ProjectTasksCharts = () => {
  const { t } = useTranslation(["tasks"])
  const { data, loading } = useQuery<TasksChartsDTO>(
    PROJECT_TASKS_CHARTS_QUERY,
    {}
  )
  const taskList = data?.tasksList
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

  return (
    <ProjectPage pageName="" loading={loading} dashboard>
      <Grid item xs={6} sx={{ padding: 1 }}>
        <Typography>Flow Chart Data</Typography>
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
    </ProjectPage>
  )
}

export default ProjectTasksCharts
