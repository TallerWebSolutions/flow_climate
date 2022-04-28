import { gql, useQuery } from "@apollo/client"
import SearchIcon from "@mui/icons-material/Search"
import AdapterDateFns from "@mui/lab/AdapterDateFns"
import DatePicker from "@mui/lab/DatePicker"
import LocalizationProvider from "@mui/lab/LocalizationProvider"
import {
  Backdrop,
  Box,
  Button,
  CircularProgress,
  FormControl,
  InputBaseComponentProps,
  InputLabel,
  MenuItem,
  Select,
  SelectChangeEvent,
  Tab,
  Tabs,
  TextField,
} from "@mui/material"
import { ChangeEvent, useCallback, useState } from "react"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import TabPanel from "../../components/TabPanel"
import { toISOFormat } from "../../lib/date"
import { Project } from "../../modules/project/project.types"
import { Team } from "../../modules/team/team.types"
import User from "../../modules/user/user.types"
import TaskCharts from "./Charts"
import TaskList from "./List"

export const SELECT_FILTERS_QUERY = gql`
  query TasksSelectFilters {
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

type TaskFiltersDTO = {
  me: User
}

export type TaskFilters = {
  page: number
  limit: number
  status?: string
  title?: string
  teamId?: string
  projectId?: string
  initiativeId?: string
  fromDate?: string | null
  untilDate?: string | null
}

type BasicSelectItem =
  | {
      id: number
      name: string
    }
  | Project
  | Team

type SelectFilterProps = {
  id: string
  label: string
  defaultValue: string
  value: any
  inputProps?: InputBaseComponentProps
  items: BasicSelectItem[]
  onChange:
    | ((event: SelectChangeEvent<any>, child: React.ReactNode) => void)
    | undefined
}

const SelectFilter = ({
  id,
  label,
  items,
  value,
  defaultValue,
  onChange,
  inputProps,
}: SelectFilterProps) => {
  return (
    <FormControl fullWidth>
      <InputLabel id={id}>{label}</InputLabel>
      <Select
        labelId={id}
        value={value ?? ""}
        label={label}
        onChange={onChange}
        inputProps={{ ...inputProps }}
      >
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

function a11yProps(index: number) {
  return {
    id: `simple-tab-${index}`,
    "aria-controls": `simple-tabpanel-${index}`,
  }
}

type TasksPageProps = {
  initialTab?: number
}

const TasksPage = ({ initialTab = 1 }: TasksPageProps) => {
  const { t } = useTranslation(["tasks"])
  const [tab, setTab] = useState(initialTab)
  const [taskSearchName, setTaskSearchName] = useState("")
  const [fromDate, setFromDate] = useState<string | null>(null)
  const [untilDate, setUntilDate] = useState<string | null>(null)
  const [taskFilters, setTaskFilters] = useState<TaskFilters>({
    page: 0,
    limit: 10,
    status: "",
  })

  const { data, loading } = useQuery<TaskFiltersDTO>(SELECT_FILTERS_QUERY)
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

  const isChartTab = tab === 0
  const company = data?.me.currentCompany!
  const projects = company.projects
  const initiatives = company.initiatives
  const teams = company.teams
  const companySlug = company.slug
  const taskTabs = [
    {
      label: t("tabs.charts"),
    },
    {
      label: t("tabs.list"),
    },
  ]
  const breadcrumbsLinks = [
    { name: String(company?.name) || "", url: String(companySlug) },
    { name: isChartTab ? t("tabs.charts") : t("tasks_list") },
  ]

  const handleStatus = (event: SelectChangeEvent<any>) => {
    const status = event.target.value
    setTaskFilters((prevState) => ({ ...prevState, status }))
  }

  const handleRefectSearch = () => {
    const fromDateISO = fromDate ? toISOFormat(fromDate) : null
    const untilDateISO = untilDate ? toISOFormat(untilDate) : null

    setTaskFilters((prevState) => ({
      ...prevState,
      title: taskSearchName,
      fromDate: fromDateISO,
      untilDate: untilDateISO,
    }))
  }

  const handleChangeTab = (tab: number) => {
    setTab(tab)
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
              onChange={handleSearchByName}
              label={t("filter.search")}
              helperText={t("filter.search_helper")}
            />
            <DatePicker
              label={t("filter.initial_date")}
              value={fromDate}
              onChange={setFromDate}
              renderInput={(params) => <TextField {...params} />}
            />
            <DatePicker
              label={t("filter.end_date")}
              value={untilDate}
              onChange={setUntilDate}
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
            <SelectFilter
              label={t("filter.initiative")}
              id="filter-initiative"
              defaultValue=""
              items={initiatives || []}
              value={taskFilters.initiativeId}
              onChange={(event) => handleSelectFilters(event, "initiativeId")}
            />
            <SelectFilter
              label={t("filter.project")}
              id="filter-project"
              defaultValue=""
              items={projects || []}
              inputProps={{
                "data-testid": "select-project",
              }}
              value={taskFilters.projectId}
              onChange={(event) => handleSelectFilters(event, "projectId")}
            />
            <SelectFilter
              label={t("filter.team")}
              id="filter-team"
              defaultValue=""
              items={teams || []}
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

        <Box
          sx={{
            mt: 2,
            mb: 6,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <Tabs value={tab} onChange={(_, tab) => handleChangeTab(tab)}>
            {taskTabs.map((tab, index) => {
              return (
                <Tab
                  key={`${index}--${tab.label}`}
                  label={tab.label}
                  {...a11yProps(index)}
                />
              )
            })}
          </Tabs>
        </Box>

        <TabPanel value={tab} index={0}>
          <TaskCharts filters={taskFilters} />
        </TabPanel>

        <TabPanel value={tab} index={1}>
          <TaskList filters={taskFilters} setFilters={setTaskFilters} />
        </TabPanel>
      </Box>
    </BasicPage>
  )
}

export default TasksPage
