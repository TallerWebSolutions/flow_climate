import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
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
  TextField,
} from "@mui/material"
import { ChangeEvent, useEffect, useState, useCallback } from "react"
import { useTranslation } from "react-i18next"
import BasicPage from "../components/BasicPage"
import { secondsToReadbleDate } from "../lib/date"
import { Task } from "../modules/task/task.types"
import { Team } from "../modules/team/team.types"
import User from "../modules/user/user.types"

const TASKS_QUERY = gql`
  query TasksPage(
    $page: Int!
    $status: String
    $title: String
    $teamId: ID
    $projectId: ID
    $initiativeId: ID
    $limit: Int
  ) {
    tasksList(
      pageNumber: $page
      status: $status
      title: $title
      teamId: $teamId
      projectId: $projectId
      initiativeId: $initiativeId
      limit: $limit
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
          name
        }
        initiative {
          name
        }
        project {
          name
        }
        demand {
          demandTitle
        }
      }
    }

    me {
      currentCompany {
        initiatives {
          id
          name
        }
        projects {
          id
          name
        }
        teams {
          id
          name
        }
      }
    }
  }
`

type TasksDTO = {
  tasksList: {
    totalCount: number
    totalDeliveredCount: number
    lastPage: number
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

type TaskFilters = {
  page: number
  limit: number
  status?: string
  title?: string
  teamId?: string
  projectId?: string
  initiativeId?: string
}

const Tasks = () => {
  const { t } = useTranslation(["tasks"])
  const [taskSearchName, setTaskSearchName] = useState("")
  const [taskFilters, setTaskFilters] = useState<TaskFilters>({
    page: 1,
    limit: 10,
    title: "",
  })

  const { data, loading } = useQuery<TasksDTO>(TASKS_QUERY, {
    variables: { ...taskFilters },
  })

  useEffect(() => console.log({ ...taskFilters }), [taskFilters])
  useEffect(() => console.log({ data }), [data])

  useEffect(() => {
    const bounceTime = setTimeout(() => {
      setTaskFilters((prevState) => ({ ...prevState, title: taskSearchName }))
    }, 1000)

    return () => clearTimeout(bounceTime)
  }, [taskSearchName])

  const handleSearchByName = useCallback(
    (event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setTaskSearchName(String(event.target.value)),
    [taskFilters]
  )

  const handleSelectFilters = useCallback(
    (
      event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>,
      prop: string
    ) => {
      const value = String(event.target.value)

      return setTaskFilters((prevState) => {
        delete prevState.initiativeId
        delete prevState.projectId
        delete prevState.teamId

        return { ...prevState, [prop]: value }
      })
    },
    [taskFilters]
  )

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const totalOfTasksPage = Number(data?.tasksList.totalPages)
  const totalOfTasks = Number(data?.tasksList.totalCount)
  const totalOfDeliveredTasks = Number(data?.tasksList.totalDeliveredCount)
  const tasks = data?.tasksList.tasks!
  const company = data?.me.currentCompany!
  const projects = company.projects
  const initiatives = company.initiatives
  const teams = company.teams

  const taskListHeadCells = [
    "ID",
    "Team",
    "Initiative",
    "Project",
    t("tasks_table.demand_title"),
    t("tasks_table.title"),
    t("tasks_table.creation_date"),
    t("tasks_table.delivery_date"),
    t("tasks_table.time_to_finish"),
  ]
  const breadcrumbsLinks = [
    { name: company.name || "", url: company.slug },
    { name: t("tasks") },
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

  const handleStatus = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const status = event.target.value
    setTaskFilters((prevState) => ({ ...prevState, status }))
  }

  return (
    <BasicPage
      title={t("tasks")}
      company={company}
      breadcrumbsLinks={breadcrumbsLinks}
    >
      <Box>
        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: "repeat(4, 1fr)",
            gridTemplateRows: "repeat(2, 1fr)",
            gridColumnGap: "16px",
            gridRowGap: "20px",
          }}
        >
          <TextField
            value={taskSearchName}
            defaultValue=""
            onChange={handleSearchByName}
            label={t("filter.search")}
            helperText={t("filter.search_helper")}
          />
          <TextField
            defaultValue=""
            label={t("filter.initial_date")}
            type="date"
            id="initial-date"
          />
          <TextField defaultValue="" label={t("filter.end_date")} type="date" />

          <TextField
            select
            label={t("filter.status")}
            defaultValue=""
            value={taskFilters.status}
            onChange={(event) => handleStatus(event)}
            SelectProps={{
              native: true,
            }}
          >
            <option value="not_finished">{t("filter.status_open")}</option>
            <option value="finished">{t("filter.status_finished")}</option>
          </TextField>

          <TextField
            select
            label={t("filter.initiative")}
            defaultValue=""
            value={taskFilters.initiativeId}
            onChange={(event) => handleSelectFilters(event, "initiativeId")}
            SelectProps={{
              native: true,
            }}
          >
            <option value="">{t("filter.select_initiative")}</option>
            {initiatives.map((initiative) => (
              <option key={initiative.id} value={initiative.id}>
                {initiative.name}
              </option>
            ))}
          </TextField>

          <TextField
            select
            label={t("filter.project")}
            defaultValue=""
            value={taskFilters.projectId}
            onChange={(event) => handleSelectFilters(event, "projectId")}
            SelectProps={{
              native: true,
            }}
          >
            <option value="">{t("filter.select_project")}</option>
            {projects.map((project) => (
              <option key={project.id} value={project.id}>
                {project.name}
              </option>
            ))}
          </TextField>

          <TextField
            select
            label={t("filter.team")}
            value={taskFilters.teamId}
            onChange={(event) => handleSelectFilters(event, "teamId")}
            SelectProps={{
              native: true,
            }}
          >
            <option value="">{t("filter.select_team")}</option>
            {teams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.name}
              </option>
            ))}
          </TextField>
        </Box>

        <TableContainer>
          <Typography color="primary" variant="h6" component="h6">
            {`${totalOfTasks} ${t("tasks")} - ${totalOfDeliveredTasks} ${t(
              "finished_tasks"
            )}`}
          </Typography>

          <Table>
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
                const baseLink = `/companies/${company.slug}`

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
                        href={`${baseLink}/initiatives/${task.initiative.id}`}
                      >
                        {task.initiative.name}
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
            page={totalOfTasksPage}
            onPageChange={(_, page) => handlePage(page)}
            onRowsPerPageChange={(event) => handleRowsPerPage(event)}
          />
        </TableContainer>
      </Box>
    </BasicPage>
  )
}

export default Tasks
