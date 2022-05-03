import { gql, useQuery } from "@apollo/client"
import { Box, CircularProgress, Typography } from "@mui/material"
import { BarDatum } from "@nivo/bar"
import { CartesianMarkerProps } from "@nivo/core"
import { SliceTooltipProps } from "@nivo/line"
import { ScatterPlotValue } from "@nivo/scatterplot"
import { ReactElement, useEffect, useState } from "react"
import { useTranslation } from "react-i18next"
import { BarChart } from "../../components/charts/BarChart"
import { LineChart } from "../../components/charts/LineChart"
import { ScatterChart } from "../../components/charts/ScatterChart"
import BarChartTooltip, {
  BarData,
} from "../../components/charts/tooltips/BarChartTooltip"
import LineChartTooltip from "../../components/charts/tooltips/LineChartTooltip"
import ScatterChartTooltip, {
  ScatterNode,
} from "../../components/charts/tooltips/ScatterChartTooltip"
import { secondsToDays } from "../../lib/date"
import { openWindow } from "../../lib/func"
import { Company } from "../../modules/company/company.types"
import { Task } from "../../modules/task/task.types"
import User from "../../modules/user/user.types"
import { TaskFilters } from "./Tasks"

const GET_TOTAL_FINISHED_TASKS = gql`
  query GetTotalOfFinishedTasks {
    tasksList {
      totalCount
    }
  }
`

const TASKS_CHARTS_QUERY = gql`
  query TasksCharts(
    $page: Int!
    $status: String
    $title: String
    $teamId: ID
    $projectId: ID
    $initiativeId: ID
    $limit: Int
    $untilDate: ISO8601Date
    $fromDate: ISO8601Date
  ) {
    tasksList(
      pageNumber: $page
      status: $status
      title: $title
      teamId: $teamId
      projectId: $projectId
      initiativeId: $initiativeId
      limit: $limit
      untilDate: $untilDate
      fromDate: $fromDate
    ) {
      tasks {
        id
        externalId
        delivered
        createdDate
        secondsToComplete
        partialCompletionTime
      }

      tasksCharts {
        xAxis
        creationArray
        throughputArray
        completionPercentilesOnTimeArray
        accumulatedCompletionPercentilesOnTimeArray
      }

      deliveredLeadTimeP65
      deliveredLeadTimeP80
      deliveredLeadTimeP95

      inProgressLeadTimeP65
      inProgressLeadTimeP80
      inProgressLeadTimeP95

      completiontimeHistogramChartData {
        keys
        values
      }
    }

    me {
      currentCompany {
        name
        slug
      }
    }
  }
`

type TasksChartsDTO = {
  me: User
  tasksList: {
    totalCount: number
    tasks: Task[]
    tasksCharts: {
      xAxis: string[]
      creationArray: number[]
      throughputArray: number[]
      completionPercentilesOnTimeArray: number[]
      accumulatedCompletionPercentilesOnTimeArray: number[]
    }
    deliveredLeadTimeP65: number
    deliveredLeadTimeP80: number
    deliveredLeadTimeP95: number
    inProgressLeadTimeP65: number
    inProgressLeadTimeP80: number
    inProgressLeadTimeP95: number
    completiontimeHistogramChartData: {
      keys: number[]
      values: number[]
    }
  }
}

type ChartData = {
  id?: number
  x: number | string | any
  y: number | string
}

type TotalFinishedTasksDTO = {
  tasksList: {
    totalCount: number
  }
}

type CompletionTimeConfidenceChart = {
  p80CompletionTime: ChartData[]
  accumulatedCompletionTime: ChartData[]
}

const voidTask = {} as Task
type TaskKey = keyof typeof voidTask

const ChartBox = ({
  children,
  title,
}: {
  children: ReactElement | ReactElement[]
  title: string
}) => {
  return (
    <Box
      sx={{
        width: "100%",
        height: 400,
        display: "flex",
        alignItems: "center",
        flexDirection: "column",
      }}
    >
      <Typography component="h3" variant="h6">
        {title}
      </Typography>

      {children}
    </Box>
  )
}

const mountTasksChartAxis = ({
  tasks,
  fieldID,
  fieldData,
}: {
  tasks?: Task[]
  fieldID: TaskKey
  fieldData: TaskKey
}): ChartData[] => {
  return tasks
    ? tasks.map((task) => {
        const daysToCompleteTask = secondsToDays(Number(task[fieldData]))

        return {
          x: task[fieldID],
          y: daysToCompleteTask,
        }
      })
    : []
}

export const buildPercentileYAxisMarker = ({
  completionTime,
  color,
  legend,
}: {
  completionTime: number | string
  legend: string
  color: string
}): CartesianMarkerProps<ScatterPlotValue> => {
  return {
    axis: "y",
    value: completionTime,
    lineStyle: { stroke: color, strokeWidth: 1 },
    legend: legend,
    legendOrientation: "horizontal",
  }
}

type TasksChartProps = {
  filters: TaskFilters
}

const TaskCharts = ({ filters }: TasksChartProps) => {
  const { t } = useTranslation(["tasks"])
  const [completionTimeData, setCompletionTimeData] = useState<ChartData[]>([])
  const [partialCompletionTimeData, setPartialCompletionTimeData] = useState<
    ChartData[]
  >([])
  const [flowChartData, setFlowChartData] = useState<BarDatum[]>([])
  const [completionTimeHistogramData, setCompletionTimeHistogramData] =
    useState<BarDatum[]>([])
  const [
    completionTimeConfidenceEvolution,
    setCompletionTimeConfidenceEvolution,
  ] = useState<CompletionTimeConfidenceChart>()
  const [company, setCompany] = useState<Company | null>(null)
  const [totalOfFinishedTasks, setTotalOfFinishedTasks] = useState<number>(0)
  const { data: totalFinishedTasksData, loading: loadingFinishedTasksData } =
    useQuery<TotalFinishedTasksDTO>(GET_TOTAL_FINISHED_TASKS)
  const { data, loading } = useQuery<TasksChartsDTO>(TASKS_CHARTS_QUERY, {
    skip: totalOfFinishedTasks === 0,
    variables: { ...filters, limit: totalOfFinishedTasks },
  })

  useEffect(() => {
    if (!loadingFinishedTasksData) {
      setTotalOfFinishedTasks(
        Number(totalFinishedTasksData?.tasksList.totalCount)
      )
    }
  }, [loadingFinishedTasksData, totalFinishedTasksData])

  useEffect(() => {
    if (!loading) {
      setCompany(data?.me.currentCompany!)

      setCompletionTimeData(
        mountTasksChartAxis({
          tasks: data?.tasksList.tasks,
          fieldID: "externalId",
          fieldData: "secondsToComplete",
        })
      )

      const tasksNotDelivered = data?.tasksList.tasks.filter(
        ({ delivered }) => !delivered
      )
      const mountedPartialCompletionChartData = tasksNotDelivered
        ? tasksNotDelivered?.map((task) => {
            const currentCompletionTime = secondsToDays(
              Number(task.partialCompletionTime)
            )

            return {
              x: task.externalId,
              y: currentCompletionTime,
            }
          })
        : []

      setPartialCompletionTimeData(mountedPartialCompletionChartData)

      const tasksChartsData = data?.tasksList.tasksCharts
      const mountedFlowChartData = tasksChartsData
        ? tasksChartsData.xAxis.map((xAxis, index) => {
            return {
              period: xAxis,
              [t("charts.flow_data_created_legend")]:
                tasksChartsData.creationArray[index],
              [t("charts.flow_data_delivered_legend")]:
                tasksChartsData.throughputArray[index],
            }
          })
        : []

      setFlowChartData(mountedFlowChartData)

      const mountedCompletionTimeConfidenceData = tasksChartsData
        ? tasksChartsData.xAxis.map((xAxis, index) => {
            return {
              x: xAxis,
              y: secondsToDays(
                tasksChartsData.completionPercentilesOnTimeArray[index]
              ),
            }
          })
        : []

      const mountedAccumulatedCompletionTime = tasksChartsData
        ? tasksChartsData.xAxis.map((xAxis, index) => {
            return {
              x: xAxis,
              y: secondsToDays(
                tasksChartsData.accumulatedCompletionPercentilesOnTimeArray[
                  index
                ]
              ),
            }
          })
        : []

      setCompletionTimeConfidenceEvolution({
        accumulatedCompletionTime: mountedAccumulatedCompletionTime,
        p80CompletionTime: mountedCompletionTimeConfidenceData,
      })

      const completionTimeHistogramData =
        data?.tasksList.completiontimeHistogramChartData
      const mountedCompletionTimeHistogramChartData: BarDatum[] =
        completionTimeHistogramData
          ? completionTimeHistogramData?.keys.map((completionTime, index) => {
              const taskCompletiomHistogramKeysInDays =
                secondsToDays(completionTime).toFixed(2)

              return {
                index,
                [t("charts.completion_time_histogram_completiontime")]:
                  taskCompletiomHistogramKeysInDays,
                [t("charts.completion_time_histogram_completiontime_x_label")]:
                  completionTimeHistogramData.values[index],
              }
            })
          : []
      // eslint-disable-next-line no-console
      console.log({ mountedCompletionTimeHistogramChartData })
      setCompletionTimeHistogramData(mountedCompletionTimeHistogramChartData)
    }
  }, [data, loading, t])

  const taskList = data?.tasksList
  const companySlug = String(company?.slug)

  const getTaskIDByExternalID = (findedExternalId: number) => {
    return taskList?.tasks.find(
      ({ externalId }) => Number(externalId) === findedExternalId
    )
  }

  const deliveredLeadTimeP65 = secondsToDays(
    Number(taskList?.deliveredLeadTimeP65)
  )
  const deliveredLeadTimeP80 = secondsToDays(
    Number(taskList?.deliveredLeadTimeP80)
  )
  const deliveredLeadTimeP95 = secondsToDays(
    Number(taskList?.deliveredLeadTimeP95)
  )

  const deliveredLeadTimeP65Marker = buildPercentileYAxisMarker({
    color: "#f80304",
    completionTime: deliveredLeadTimeP65,
    legend: t("charts.control_completion_time_p65_marker", {
      days: deliveredLeadTimeP65,
    }),
  })

  const deliveredLeadTimeP80Marker = buildPercentileYAxisMarker({
    color: "#daa521",
    completionTime: deliveredLeadTimeP80,
    legend: t("charts.control_completion_time_p80_marker", {
      days: deliveredLeadTimeP80,
    }),
  })

  const deliveredLeadTimeP95Marker = buildPercentileYAxisMarker({
    color: "#1e8b16",
    completionTime: deliveredLeadTimeP95,
    legend: t("charts.control_completion_time_p95_marker", {
      days: deliveredLeadTimeP95,
    }),
  })

  const completionTimeChartData = [
    {
      id: t("charts.completion_time_legend"),
      data: completionTimeData,
    },
  ]

  const partialCompletionTimeChartData = [
    {
      id: t("charts.completion_time_legend"),
      data: partialCompletionTimeData,
    },
  ]

  const completionTimeEvolutionChartData = [
    {
      id: t("charts.completion_time_confidence_p80_legend"),
      data: completionTimeConfidenceEvolution
        ? completionTimeConfidenceEvolution.p80CompletionTime
        : [],
    },
    {
      id: t("charts.completion_time_confidence_p80_acumulated_legend"),
      data: completionTimeConfidenceEvolution
        ? completionTimeConfidenceEvolution.accumulatedCompletionTime
        : [],
    },
  ]

  return loading || loadingFinishedTasksData ? (
    <Box
      sx={{
        width: "100%",
        height: 200,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <CircularProgress color="secondary" />
    </Box>
  ) : (
    <Box
      sx={{
        display: "grid",
        gridTemplateColumns: "repeat(2, 1fr)",
        gridTemplateRows: "repeat(2, 1fr)",
        gridColumnGap: "16px",
        gridRowGap: "20px",
        mb: 6,
      }}
    >
      <ChartBox title={t("charts.control_completion_time_title")}>
        <ScatterChart
          axisLeftLegend={t("charts.days")}
          data={completionTimeChartData}
          props={{
            markers: [
              deliveredLeadTimeP65Marker,
              deliveredLeadTimeP80Marker,
              deliveredLeadTimeP95Marker,
            ],
            tooltip: (data: { node: ScatterNode }) => {
              return (
                <ScatterChartTooltip
                  xLabel={t("charts.control_completion_time_tooltip_x_legend")}
                  node={data.node}
                />
              )
            },
          }}
          onClick={({ xValue }) => {
            const taskExternalID = Number(xValue)
            const taskID = getTaskIDByExternalID(taskExternalID)
            openWindow(`/companies/${companySlug}/tasks/${taskID?.id}`)
          }}
        />
      </ChartBox>

      <ChartBox title={t("charts.current_partial_completion_title")}>
        <ScatterChart
          axisLeftLegend={t("charts.days")}
          data={partialCompletionTimeChartData}
          props={{
            markers: [
              deliveredLeadTimeP65Marker,
              deliveredLeadTimeP80Marker,
              deliveredLeadTimeP95Marker,
            ],
            xScale: {
              type: "linear",
              min: "auto",
              max: "auto",
              reverse: true,
            },
            tooltip: (data: { node: ScatterNode }) => {
              return (
                <ScatterChartTooltip
                  xLabel={t(
                    "charts.current_partial_completion_tooltip_x_legend"
                  )}
                  node={data.node}
                />
              )
            },
          }}
          onClick={({ xValue }) => {
            const taskExternalID = Number(xValue)
            const taskID = getTaskIDByExternalID(taskExternalID)
            openWindow(`/companies/${companySlug}/tasks/${taskID?.id}`)
          }}
        />
      </ChartBox>

      <ChartBox title={t("charts.flow_data_title")}>
        <BarChart
          axisLeftLegend={t("charts.demands")}
          data={flowChartData}
          keys={[
            t("charts.flow_data_created_legend"),
            t("charts.flow_data_delivered_legend"),
          ]}
          axisBottomLegend={t("charts.flow_data_period_legend")}
          indexBy="period"
          tooltip={(data: BarData) => {
            return (
              <BarChartTooltip
                xLabel={t("charts.flow_data_tooltip_x_legend")}
                data={data}
              />
            )
          }}
        />
      </ChartBox>

      <ChartBox title={t("charts.completion_time_evolution_title")}>
        <LineChart
          axisLeftLegend={t("charts.days")}
          data={completionTimeEvolutionChartData}
          props={{
            margin: { top: 50, right: 60, bottom: 65, left: 60 },
            axisBottom: {
              legend: t("charts.completion_time_evolution_weeks_legend"),
              legendOffset: 60,
              tickRotation: -37,
              legendPosition: "middle",
            },
            enableSlices: "x",
            sliceTooltip: ({ slice }: SliceTooltipProps) => (
              <LineChartTooltip
                slice={slice}
                xLabel={t("charts.completion_time_evolution_tooltip_x_legend")}
              />
            ),
            legends: [
              {
                anchor: "top",
                direction: "row",
                toggleSerie: true,
                justify: false,
                translateX: 0,
                translateY: -25,
                itemsSpacing: 0,
                itemDirection: "left-to-right",
                itemWidth: 200,
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
      </ChartBox>

      <ChartBox title={t("charts.completion_time_histogram_chart")}>
        <BarChart
          data={completionTimeHistogramData}
          keys={[t("charts.completion_time_histogram_completiontime")]}
          indexBy={t(
            "charts.completion_time_histogram_completiontime_x_label"
          )}
          axisLeftLegend={t(
            "charts.completion_time_histogram_completiontime_y_label"
          )}
          axisBottomLegend={t(
            "charts.completion_time_histogram_completiontime_x_label"
          )}
        />
      </ChartBox>
    </Box>
  )
}

export default TaskCharts
