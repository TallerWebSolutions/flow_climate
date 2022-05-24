import { BarDatum } from "@nivo/bar"
import { TasksCharts } from "../../pages/Tasks/List"
import { TasksList } from "./task.types"

export const normalizeTasksFlowChart = (tasksList?: TasksList) => {
  const flowChartGroupNames: (keyof TasksCharts)[] = ["creation", "throughput"]
  const flowChartData: BarDatum[] =
    tasksList?.tasksCharts.xAxis.map((key, indexAxis) => {
      const group: BarDatum = { key }
      flowChartGroupNames.forEach((name) => {
        const value = Number(tasksList.tasksCharts[name][indexAxis]) || ""
        group[name] = value
      })
      return group
    }) || []

  return { flowChartGroupNames, flowChartData }
}
