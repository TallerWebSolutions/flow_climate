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
  InputLabel,
  MenuItem,
  Select,
  SelectChangeEvent,
  FormControl,
  Button,
} from "@mui/material"
import SearchIcon from "@mui/icons-material/Search"
import DatePicker from "@mui/lab/DatePicker"
import AdapterDateFns from "@mui/lab/AdapterDateFns"
import LocalizationProvider from "@mui/lab/LocalizationProvider"
import { ChangeEvent, useEffect, useState, useCallback } from "react"
import { useTranslation } from "react-i18next"
import BasicPage from "../components/BasicPage"
import { secondsToReadbleDate, toISOFormat } from "../lib/date"
import { Task } from "../modules/task/task.types"
import User from "../modules/user/user.types"
import { Project } from "../modules/project/project.types"
import { Team } from "../modules/team/team.types"

const TASKS_QUERY = gql`
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
        name
        slug
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
  fromDate?: string
  untilDate?: string
}

const normalizeDateToDatePicker = (date: any): string | null => {
  return date !== undefined ? date : null
}

type BasicSelectItem =
  | {
      id: number
      name: string
    }
  | Project
  | Team

type SelectItemsProps = {
  id: string
  label: string
  defaultValue: string
  value: any
  items: BasicSelectItem[]
  onChange:
    | ((event: SelectChangeEvent<any>, child: React.ReactNode) => void)
    | undefined
}

const SelectItems = ({
  id,
  label,
  items,
  value,
  defaultValue,
  onChange,
}: SelectItemsProps) => {
  return (
    <FormControl fullWidth>
      <InputLabel id={id}>{label}</InputLabel>
      <Select labelId={id} value={value} label={label} onChange={onChange}>
        <MenuItem value="">{defaultValue}</MenuItem>
        {items.map((item) => (
          <MenuItem key={`${item.id}--${item.name}`} value={item.id}>
            {item.name}
          </MenuItem>
        ))}
      </Select>
    </FormControl>
  )
}

const Tasks = () => {
  const { t } = useTranslation(["tasks"])
  const [taskSearchName, setTaskSearchName] = useState("")
  const [taskFilters, setTaskFilters] = useState<TaskFilters>({
    page: 0,
    limit: 10,
    title: "",
    status: "",
  })

  const { data, loading } = useQuery<TasksDTO>(TASKS_QUERY, {
    variables: { ...taskFilters },
  })

  const handleSearchByName = useCallback(
    (event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setTaskSearchName(String(event.target.value)),
    []
  )

  const handleSelectFilters = useCallback(
    (event: SelectChangeEvent<any>, queryParam: string) => {
      const value = String(event.target.value)

      return setTaskFilters((prevState) => {
        delete prevState.initiativeId
        delete prevState.projectId
        delete prevState.teamId

        return { ...prevState, [queryParam]: value }
      })
    },
    []
  )

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const totalOfTasks = Number(data?.tasksList.totalCount)
  const totalOfDeliveredTasks = Number(data?.tasksList.totalDeliveredCount)
  const tasks = data?.tasksList.tasks!
  const company = data?.me.currentCompany!
  const projects = company.projects
  const initiatives = company.initiatives
  const teams = company.teams

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
    { name: company.name || "", url: company.slug },
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

  const handleStatus = (event: SelectChangeEvent<any>) => {
    const status = event.target.value
    setTaskFilters((prevState) => ({ ...prevState, status }))
  }

  const handleDateFilters = (date: string, queryParam: string) => {
    const isoDate = toISOFormat(date)
    setTaskFilters((prevState) => ({ ...prevState, [queryParam]: isoDate }))
  }

  const handleRefectSearch = () => {
    setTaskFilters((prevState) => ({ ...prevState, title: taskSearchName }))
  }

  return (
    <BasicPage
      title={t("tasks")}
      company={company}
      breadcrumbsLinks={breadcrumbsLinks}
    >
      <Box>
        <LocalizationProvider dateAdapter={AdapterDateFns}>
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
            <DatePicker
              label={t("filter.initial_date")}
              value={normalizeDateToDatePicker(taskFilters.fromDate)}
              onChange={(date) => handleDateFilters(String(date), "fromDate")}
              renderInput={(params) => <TextField {...params} />}
            />
            <DatePicker
              label={t("filter.end_date")}
              value={normalizeDateToDatePicker(taskFilters.untilDate)}
              onChange={(date) => handleDateFilters(String(date), "untilDate")}
              renderInput={(params) => <TextField {...params} />}
            />
            <FormControl fullWidth>
              <InputLabel id="status-filter">{t("filter.status")}</InputLabel>
              <Select
                labelId="status-filter"
                label={t("filter.status")}
                value={taskFilters.status}
                onChange={(event) => handleStatus(event)}
              >
                <MenuItem value="">{t("filter.select_status")}</MenuItem>
                <MenuItem value="not_finished">
                  {t("filter.status_open")}
                </MenuItem>
                <MenuItem value="finished">
                  {t("filter.status_finished")}
                </MenuItem>
              </Select>
            </FormControl>
            <SelectItems
              label={t("filter.initiative")}
              id="filter-status"
              defaultValue=""
              items={initiatives}
              value={taskFilters.initiativeId}
              onChange={(event) => handleSelectFilters(event, "initiativeId")}
            />
            <SelectItems
              label={t("filter.project")}
              id="filter-status"
              defaultValue=""
              items={projects}
              value={taskFilters.projectId}
              onChange={(event) => handleSelectFilters(event, "projectId")}
            />
            <SelectItems
              label={t("filter.team")}
              id="filter-status"
              defaultValue=""
              items={teams}
              value={taskFilters.teamId}
              onChange={(event) => handleSelectFilters(event, "teamId")}
            />
            <Button
              onClick={handleRefectSearch}
              sx={{ width: "60px", height: "55px" }}
            >
              <SearchIcon fontSize="large" color="primary" />
            </Button>
          </Box>
        </LocalizationProvider>

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
            page={taskFilters.page}
            onPageChange={(_, page) => handlePage(page)}
            onRowsPerPageChange={(event) => handleRowsPerPage(event)}
          />
        </TableContainer>
      </Box>
    </BasicPage>
  )
}

export default Tasks
