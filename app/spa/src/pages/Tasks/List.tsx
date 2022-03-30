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
import { ChangeEvent, useEffect, useState } from "react"
import { useTranslation } from "react-i18next"
import { useLocation } from "react-router-dom"
import TasksPage, { TaskFilters } from "../../components/TaskPage"
import { secondsToReadbleDate } from "../../lib/date"
import { Company } from "../../modules/company/company.types"
import { Task } from "../../modules/task/task.types"
import User from "../../modules/user/user.types"

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
      totalCount
      totalDeliveredCount
      totalPages

      tasks {
        id
        title
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
          demandTitle
        }
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

type TasksListDTO = {
  tasksList: {
    totalCount: number
    totalDeliveredCount: number
    totalPages: number
    tasks: Task[]
  }
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

const TasksList = () => {
  const { t } = useTranslation(["tasks"])
  const { pathname } = useLocation()
  const [tasks, setTasks] = useState<Task[]>([])
  const [company, setCompany] = useState<Company | null>(null)
  const [totalOfTasks, setTotalOfTasks] = useState(0)
  const [totalOfDeliveredTasks, setTotalOfDeliveredTasks] = useState(0)
  const [taskFilters, setTaskFilters] = useState<TaskFilters>({
    page: 0,
    limit: 10,
  })

  const { data, loading } = useQuery<TasksListDTO>(TASKS_LIST_QUERY, {
    variables: { ...taskFilters },
  })

  useEffect(() => {
    if (!loading) {
      setTasks(data?.tasksList.tasks!)
      setCompany(data?.me.currentCompany!)
      setTotalOfTasks(Number(data?.tasksList.totalCount))
      setTotalOfDeliveredTasks(Number(data?.tasksList.totalDeliveredCount))
    }
  }, [data, loading])

  const taskListHeadCells = [
    "ID",
    t("tasks_table.team"),
    t("tasks_table.initiative"),
    t("tasks_table.project"),
    t("tasks_table.demand_title"),
    t("tasks_table.title"),
    t("tasks_table.creation_date"),
    t("tasks_table.delivery_date"),
    t("tasks_table.time_to_finish"),
  ]
  const breadcrumbsLinks = [
    { name: String(company?.name) || "", url: String(company?.slug) },
    { name: t("tasks_list") },
  ]

  const handleRowsPerPage = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const quantity: number = Number(event.target.value)
    setTaskFilters((prevState) => ({ ...prevState, limit: quantity }))
  }

  const handlePage = (newPage: number) => {
    setTaskFilters((prevState) => ({ ...prevState, page: newPage }))
  }

  return (
    <TasksPage
      title={t("tasks")}
      breadcrumbsLinks={breadcrumbsLinks}
      pathname={pathname}
      onFiltersChange={(filters) => {
        setTaskFilters((prevState) => ({ ...prevState, ...filters }))
      }}
    >
      {loading ? (
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
            {`${totalOfTasks} ${t("tasks")} - ${totalOfDeliveredTasks} ${t(
              "finished_tasks"
            )}`}
          </Typography>

          <Table data-testid="task-list">
            <TableHead
              sx={{
                borderBottom: "1px solid",
                borderBottomColor: "#ccc",
              }}
            >
              <TableRow>
                {taskListHeadCells.map((cellName, index) => (
                  <TableCell key={`${index}--${cellName}`}>
                    {cellName}
                  </TableCell>
                ))}
              </TableRow>
            </TableHead>

            <TableBody>
              {tasks.map((task, index) => {
                const baseLink = `/companies/${company?.slug}`

                return (
                  <TableRow
                    sx={{
                      borderBottom: "1px solid",
                      borderBottomColor: "#ccc",
                    }}
                    key={`${task.title}--${index}`}
                  >
                    <TableCell padding="checkbox">
                      <Link href={`${baseLink}/tasks/${task.id}`}>
                        {task.id}
                      </Link>
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
                    <TableCell padding="checkbox">{task.title}</TableCell>
                    <TableCell padding="checkbox">{task.createdDate}</TableCell>
                    <TableCell padding="checkbox">{task.endDate}</TableCell>
                    <TableCell padding="checkbox">
                      {normalizeTimeToFinish(
                        task.secondsToComplete,
                        task.partialCompletionTime
                      )}
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
            count={totalOfTasks}
            rowsPerPage={taskFilters.limit}
            page={taskFilters.page}
            onPageChange={(_, page) => handlePage(page)}
            onRowsPerPageChange={(event) => handleRowsPerPage(event)}
          />
        </TableContainer>
      )}
    </TasksPage>
  )
}

export default TasksList
