import { gql, useQuery } from "@apollo/client"
import {
  Box,
  CircularProgress,
  Link,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TablePagination,
  TableRow,
  Typography,
} from "@mui/material"
import { ChangeEvent, useContext } from "react"
import { useTranslation } from "react-i18next"

import { TaskFilters } from "./TasksList"
import { MeContext } from "../../../contexts/MeContext"
import { secondsToReadbleDate } from "../../../lib/date"
import { Task } from "../task.types"
import User from "../../user/user.types"
import DateLocale from "../../../components/ui/DateLocale"

export const TASKS_LIST_QUERY = gql`
  query TasksPage(
    $page: Int!
    $status: String
    $title: String
    $teamId: ID
    $projectId: ID
    $initiativeId: ID
    $limit: Int
    $untilDate: ISO8601Date
    $fromDate: ISO8601Date
    $portfolioUnit: String
    $taskType: String
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
      portfolioUnit: $portfolioUnit
      taskType: $taskType
    ) {
      totalCount
      totalDeliveredCount
      totalPages

      tasks {
        id
        title
        taskType
        createdDate
        endDate
        secondsToComplete
        partialCompletionTime
        team {
          id
          name
        }
        initiative {
          id
          name
        }
        project {
          id
          name
        }
        demand {
          id
          demandTitle
          portfolioUnit {
            id
            name
          }
        }
      }
    }
  }
`

export type TasksCharts = {
  accumulatedCompletionPercentilesOnTimeArray: number[]
  completionPercentilesOnTimeArray: number[]
  creation: number[]
  throughput: number[]
  xAxis: string[]
}

export type TasksList = {
  totalCount: number
  totalDeliveredCount: number
  totalPages: number
  tasksCharts?: TasksCharts
  tasks: Task[]
}

type TasksListDTO = {
  tasksList: TasksList
  me: User
}

const normalizeTimeToFinish = (
  secondsToComplete: number,
  partialCompletionTime: number
) => {
  if (!secondsToComplete) {
    return secondsToReadbleDate(partialCompletionTime)
  }

  return secondsToReadbleDate(secondsToComplete)
}

type TaskListProps = {
  filters: TaskFilters
  setFilters: React.Dispatch<React.SetStateAction<TaskFilters>>
}

const TasksTable = ({ filters, setFilters }: TaskListProps) => {
  const { t } = useTranslation(["tasks"])

  const { data, loading } = useQuery<TasksListDTO>(TASKS_LIST_QUERY, {
    variables: { ...filters },
  })
  const { me } = useContext(MeContext)

  const taskListHeadCells = [
    "ID",
    t("tasks_table.team"),
    t("tasks_table.initiative"),
    t("tasks_table.project"),
    t("tasks_table.demandTitle"),
    t("tasks_table.taskType"),
    t("tasks_table.title"),
    t("tasks_table.creationDate"),
    t("tasks_table.deliveryDate"),
    t("tasks_table.timeToFinish"),
    t("tasks_table.portfolioUnit"),
  ]

  const handleRowsPerPage = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const quantity: number = Number(event.target.value)
    setFilters((prevState) => ({ ...prevState, limit: quantity }))
  }

  const handlePage = (newPage: number) => {
    setFilters((prevState) => ({ ...prevState, page: newPage }))
  }

  const tasksList = data?.tasksList.tasks || []

  return loading ? (
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
    <TableContainer>
      <Typography color="primary" variant="h6" component="h6">
        {`${data?.tasksList.totalCount} ${t("tasks")} - ${
          data?.tasksList.totalDeliveredCount
        } ${t("finished_tasks")}`}
      </Typography>

      <Table data-testid="task-list" table-layout="fixed">
        <TableHead
          sx={{
            borderBottom: "1px solid",
            borderBottomColor: "#ccc",
          }}
        >
          <TableRow>
            {taskListHeadCells.map((cellName, index) => (
              <TableCell key={`${index}--${cellName}`}>{cellName}</TableCell>
            ))}
          </TableRow>
        </TableHead>

        <TableBody>
          {tasksList.map((task, index) => {
            const baseLink = `/companies/${me?.currentCompany?.slug}`

            return (
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",
                }}
                key={`${task.title}--${index}`}
              >
                <TableCell padding="checkbox">
                  <Link href={`${baseLink}/tasks/${task.id}`}>{task.id}</Link>
                </TableCell>
                <TableCell padding="checkbox">
                  <Link href={`${baseLink}/teams/${task.team.id}`}>
                    {task.team.name}
                  </Link>
                </TableCell>
                <TableCell padding="checkbox">
                  <Link
                    href={
                      task.initiative
                        ? `${baseLink}/initiatives/${task.initiative?.id}`
                        : "#"
                    }
                  >
                    {task.initiative?.name}
                  </Link>
                </TableCell>
                <TableCell padding="checkbox">
                  <Link href={`${baseLink}/projects/${task.project.id}`}>
                    {task.project.name}
                  </Link>
                </TableCell>
                <TableCell padding="checkbox">
                  {task.demand.demandTitle}
                </TableCell>
                <TableCell padding="checkbox">{task.taskType}</TableCell>
                <TableCell padding="checkbox">{task.title}</TableCell>
                <TableCell padding="checkbox">
                  <DateLocale time date={task.createdDate} />
                </TableCell>
                <TableCell padding="checkbox">
                  {task.endDate ? <DateLocale time date={task.endDate} /> : ""}
                </TableCell>
                <TableCell padding="checkbox">
                  {normalizeTimeToFinish(
                    task.secondsToComplete,
                    task.partialCompletionTime
                  )}
                </TableCell>
                <TableCell width={200}>
                  {task.demand.portfolioUnit?.name}
                </TableCell>
              </TableRow>
            )
          })}
        </TableBody>
      </Table>

      <TablePagination
        labelRowsPerPage={t("tasks_table.rows_per_page")}
        labelDisplayedRows={({ from, to, count }) => {
          return `${from}-${to} ${t(
            "tasks_table.count_displayed_items_separator"
          )} ${count}`
        }}
        rowsPerPageOptions={[5, 10, 25]}
        component="div"
        count={data?.tasksList.totalCount || 0}
        rowsPerPage={filters.limit || 10}
        page={filters.page}
        onPageChange={(_, page) => handlePage(page)}
        onRowsPerPageChange={(event) => handleRowsPerPage(event)}
      />
    </TableContainer>
  )
}

export default TasksTable
