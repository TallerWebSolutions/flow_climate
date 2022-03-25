import { gql, useQuery } from "@apollo/client"
import { Box, CircularProgress, Typography } from "@mui/material"
import { ReactElement, useEffect, useState } from "react"
import { useTranslation } from "react-i18next"
import { useLocation } from "react-router-dom"
import { BarChart } from "../../components/charts/BarChart"
import { LineChart } from "../../components/charts/LineChart"
import { ScatterChart } from "../../components/charts/ScatterChart"
import TasksPage, { TaskFilters } from "../../components/TaskPage"
import { Company } from "../../modules/company/company.types"
import { Task } from "../../modules/task/task.types"
import User from "../../modules/user/user.types"

const HOURS_IN_ONE_DAY = 24
const ONE_HOUR_IN_SECONDS = 60 * 60
const ONE_DAY_IN_SECONDS = ONE_HOUR_IN_SECONDS * HOURS_IN_ONE_DAY

const GET_TOTAL_FINISHED_TASKS = gql`
  query GetTotalOfFinishedTasks {
    tasksList {
      totalCount
    }
  }
`

type TotalFinishedTasksDTO = {
  tasksList: {
    totalCount: number
  }
}

const TASKS_CHARTS_QUERY = gql`
  query TasksCharts($limit: Int) {
    tasksList(limit: $limit) {
      tasks {
        externalId
        delivered
        secondsToComplete
        partialCompletionTime
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
  }
}

type ChartData = {
  x: number
  y: number
}

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
        height: 350,
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

const voidTask = {} as Task
type TaskKey = keyof typeof voidTask

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
        const daysToCompleteTask = Number(
          (Number(task[fieldData]) / ONE_DAY_IN_SECONDS).toFixed(2)
        )

        return {
          x: task[fieldID] as number,
          y: daysToCompleteTask,
        }
      })
    : []
}

const Charts = () => {
  const { t } = useTranslation(["tasks"])
  const { pathname } = useLocation()
  const [completionTimeData, setCompletionTimeData] = useState<ChartData[]>([])
  const [partialCompletionTimeData, setPartialCompletionTimeData] = useState<
    ChartData[]
  >([])
  const [company, setCompany] = useState<Company | null>(null)
  const [taskFilters, setTaskFilters] = useState<TaskFilters>({
    page: 0,
    limit: 10,
  })

  const [totalOfFinishedTasks, setTotalOfFinishedTasks] = useState<number>(0)
  const { data: totalFinishedTasksData, loading: loadingFinishedTasksData } =
    useQuery<TotalFinishedTasksDTO>(GET_TOTAL_FINISHED_TASKS)

  const { data, loading } = useQuery<TasksChartsDTO>(TASKS_CHARTS_QUERY, {
    skip: totalOfFinishedTasks === 0,
    variables: { ...taskFilters, limit: totalOfFinishedTasks },
  })

  useEffect(() => {
    if (!loadingFinishedTasksData) {
      setTotalOfFinishedTasks(
        Number(totalFinishedTasksData?.tasksList.totalCount)
      )
    }
  }, [loadingFinishedTasksData])

  useEffect(() => {
    if (!loading) {
      setCompany(data?.me.currentCompany!)

      const mountedCompletionTimeChartData = mountTasksChartAxis({
        tasks: data?.tasksList.tasks,
        fieldID: "externalId",
        fieldData: "secondsToComplete",
      })

      setCompletionTimeData(mountedCompletionTimeChartData)

      const tasksNotDelivered = data?.tasksList.tasks.filter(
        ({ delivered }) => !delivered
      )
      const mountedPartialCompletionChartData = mountTasksChartAxis({
        tasks: tasksNotDelivered,
        fieldID: "externalId",
        fieldData: "partialCompletionTime",
      })

      setPartialCompletionTimeData(mountedPartialCompletionChartData)
    }
  }, [data, loading])

  const breadcrumbsLinks = [
    { name: String(company?.name) || "", url: String(company?.slug) },
    { name: t("charts") },
  ]

  const completionTimeChartData = [
    {
      id: t("graphs.completion_time_data_legend"),
      data: completionTimeData,
    },
  ]

  const partialCompletionTimeChartData = [
    {
      id: t("graphs.completion_time_data_legend"),
      data: partialCompletionTimeData,
    },
  ]

  const barMock = [
    {
      country: "AD",
      "hot dog": 30,
      burger: 32,
      sandwich: 130,
      kebab: 20,
      fries: 106,
      donut: 149,
    },
  ]

  return (
    <TasksPage
      title={t("tasks")}
      breadcrumbsLinks={breadcrumbsLinks}
      pathname={pathname}
      onFiltersChange={(filters) => {
        setTaskFilters((prevState) => ({ ...prevState, ...filters }))
      }}
    >
      {loading || loadingFinishedTasksData ? (
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
          }}
        >
          <ChartBox title={t("graphs.control_completion_time_title")}>
            <ScatterChart
              axisLeftLegend={t("graphs.days")}
              data={completionTimeChartData}
            />
          </ChartBox>

          <ChartBox title={t("graphs.current_partial_completion_title")}>
            <ScatterChart
              axisLeftLegend={t("graphs.days")}
              data={partialCompletionTimeChartData}
            />
          </ChartBox>

          <ChartBox title={t("graphs.flow_data_title")}>
            <BarChart axisLeftLegend={t("graphs.demands")} data={barMock} />
          </ChartBox>

          <ChartBox title={t("graphs.lead_time_evolution_title")}>
            <LineChart
              axisLeftLegend={t("graphs.days")}
              data={completionTimeChartData}
            />
          </ChartBox>
        </Box>
      )}
    </TasksPage>
  )
}

export default Charts
