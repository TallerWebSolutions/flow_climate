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
    $pageParam: Int!
    $limit: Int
    $title: String
    $status: String
  ) {
    tasks(
      pageParam: $pageParam
      limit: $limit
      title: $title
      status: $status
    ) {
      id
      demand {
        id
        demandTitle
      }
      createdDate
      endDate
      secondsToComplete
      partialCompletionTime
    }

    me {
      language
      currentCompany {
        name
        slug
      }
    }

    teams {
      id
      name
    }
  }
`

type TasksDTO = {
  tasks: Task[]
  me: User
  teams: Team[]
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

const Tasks = () => {
  const { t } = useTranslation(["tasks"])
  const [taskSearchName, setTaskSearchName] = useState("")
  const [taskFilters, setTaskFilters] = useState({
    pageParam: 1,
    limit: 10,
    title: "",
    status: "not_finished",
  })

  const { data, loading } = useQuery<TasksDTO>(TASKS_QUERY, {
    variables: { ...taskFilters },
  })

  useEffect(() => console.log({ ...taskFilters }), [taskFilters])

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

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const tasks = data?.tasks!
  const numberOfTasks = tasks.length
  const company = data?.me.currentCompany!
  const teams = data?.teams!

  const taskListHeadCells = [
    "ID",
    t("tasks_table.demand"),
    t("tasks_table.demand_title"),
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
    setTaskFilters((prevState) => ({ ...prevState, pageParam: newPage }))
  }

  const handleStatus = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const status = event.target.value
    setTaskFilters((prevState) => ({ ...prevState, status }))
  }

  const handleTeam = (
    event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const teamId = Number(event.target.value)
    setTaskFilters((prevState) => ({ ...prevState, teamId }))
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
            onChange={handleSearchByName}
            label={t("filter.search")}
            helperText={t("filter.search_helper")}
          />
          <TextField placeholder={t("filter.initial_date")} type="date" />
          <TextField label={t("filter.end_date")} type="date" />

          <TextField
            select
            label={t("filter.status")}
            value={taskFilters.status}
            onChange={handleStatus}
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
            value={teams[0]}
            onChange={() => {}}
            SelectProps={{
              native: true,
            }}
          >
            {teams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.name}
              </option>
            ))}
          </TextField>

          <TextField
            select
            label={t("filter.project")}
            value={teams[0]}
            onChange={() => {}}
            SelectProps={{
              native: true,
            }}
          >
            {teams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.name}
              </option>
            ))}
          </TextField>

          <TextField
            select
            label={t("filter.team")}
            value={teams[0]}
            onChange={handleTeam}
            SelectProps={{
              native: true,
            }}
          >
            {teams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.name}
              </option>
            ))}
          </TextField>
        </Box>

        <TableContainer>
          <Typography color="primary" variant="h6" component="h6">
            {`877 ${t("tasks")} - 405 ${t("finished_tasks")}`}
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
              {tasks.map((row, index) => (
                <TableRow
                  sx={{
                    borderBottom: "1px solid",
                    borderBottomColor: "#ccc",
                  }}
                  key={`${row.demand}--${index}`}
                >
                  <TableCell padding="checkbox">
                    <Link href={`/companies/${company.slug}/tasks/${row.id}`}>
                      {row.id}
                    </Link>
                  </TableCell>
                  <TableCell padding="checkbox">{row.demand.id}</TableCell>
                  <TableCell padding="checkbox">
                    {row.demand.demandTitle}
                  </TableCell>
                  <TableCell padding="checkbox">{row.createdDate}</TableCell>
                  <TableCell padding="checkbox">{row.endDate}</TableCell>
                  <TableCell padding="checkbox">
                    {normalizeTimeToFinish(
                      row.secondsToComplete,
                      row.partialCompletionTime
                    )}
                  </TableCell>
                </TableRow>
              ))}
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
            count={numberOfTasks}
            rowsPerPage={taskFilters.limit}
            page={taskFilters.pageParam}
            onPageChange={(_, page) => handlePage(page)}
            onRowsPerPageChange={(event) => handleRowsPerPage(event)}
          />
        </TableContainer>
      </Box>
    </BasicPage>
  )
}

export default Tasks
