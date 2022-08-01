import SearchIcon from "@mui/icons-material/Search"
import AdapterDateFns from "@mui/lab/AdapterDateFns"
import DatePicker from "@mui/lab/DatePicker"
import LocalizationProvider from "@mui/lab/LocalizationProvider"
import {
  FormControl,
  InputLabel,
  MenuItem,
  Select,
  Box,
  Button,
  TextField,
  SelectChangeEvent,
  InputBaseComponentProps,
  TextFieldProps,
} from "@mui/material"
import {
  ChangeEvent,
  Dispatch,
  ReactNode,
  SetStateAction,
  useCallback,
  useContext,
  useState,
} from "react"
import { useTranslation } from "react-i18next"

import { toISOFormat } from "../lib/date"
import { MeContext } from "../contexts/MeContext"
import { Tabs } from "./Tabs"
import BasicPage, { BasicPageProps } from "./BasicPage"
import { Project } from "../modules/project/project.types"
import { Team } from "../modules/team/team.types"
import { TaskFilters } from "../pages/Tasks/Tasks"

type TaskPageProps = {
  children: ReactNode | ReactNode[]
  setFilters: Dispatch<SetStateAction<TaskFilters>>
  filters: TaskFilters
  charts?: boolean
} & BasicPageProps

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
  value: string
  inputProps?: InputBaseComponentProps
  items: BasicSelectItem[]
  onChange?: (event: SelectChangeEvent<any>, child: React.ReactNode) => void
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

const TasksPage = ({
  children,
  filters,
  setFilters,
  charts = false,
  ...props
}: TaskPageProps) => {
  const { t } = useTranslation(["tasks"])
  const { me } = useContext(MeContext)
  const company = me?.currentCompany
  const companySlug = company?.slug

  const taskTabs = [
    {
      label: t("tabs.charts"),
      to: `/companies/${companySlug}/tasks/charts`,
    },
    {
      label: t("tabs.list"),
      to: `/companies/${companySlug}/tasks`,
    },
  ]

  const [taskSearchName, setTaskSearchName] = useState("")
  const [fromDate, setFromDate] = useState<string | null>(null)
  const [untilDate, setUntilDate] = useState<string | null>(null)

  const projects = company?.projects
  const initiatives = company?.initiatives
  const teams = company?.teams

  const handleSearchByName = useCallback(
    (event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setTaskSearchName(String(event.target.value)),
    []
  )

  const handleSelectFilters = useCallback(
    (event: SelectChangeEvent<any>, queryParam: string) => {
      const value = String(event.target.value)

      return setFilters((prevState: any) => {
        delete prevState.initiativeId
        delete prevState.projectId
        delete prevState.teamId

        return { ...prevState, [queryParam]: value }
      })
    },
    [setFilters]
  )

  const handleStatus = (event: SelectChangeEvent<any>) => {
    const status = event.target.value
    setFilters((prevState: any) => ({ ...prevState, status }))
  }

  const handleRefectSearch = () => {
    const fromDateISO = fromDate ? toISOFormat(fromDate) : null
    const untilDateISO = untilDate ? toISOFormat(untilDate) : null

    setFilters((prevState: any) => ({
      ...prevState,
      title: taskSearchName,
      fromDate: fromDateISO,
      untilDate: untilDateISO,
    }))
  }

  return (
    <BasicPage {...props}>
      {taskTabs && (
        <Box
          sx={{
            mt: 2,
            mb: 6,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <Tabs
            tabs={taskTabs}
            currentPath={charts ? taskTabs[0].to : taskTabs[1].to}
          />
        </Box>
      )}
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
            renderInput={(params: TextFieldProps) => <TextField {...params} />}
          />
          <DatePicker
            label={t("filter.end_date")}
            value={untilDate}
            onChange={setUntilDate}
            renderInput={(params: TextFieldProps) => <TextField {...params} />}
          />
          <FormControl fullWidth>
            <InputLabel id="status-filter">{t("filter.status")}</InputLabel>
            <Select
              labelId="status-filter"
              label={t("filter.status")}
              value={filters.status}
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
            value={filters.initiativeId || ""}
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
            value={filters.projectId || ""}
            onChange={(event) => handleSelectFilters(event, "projectId")}
          />
          <SelectFilter
            label={t("filter.team")}
            id="filter-team"
            defaultValue=""
            items={teams || []}
            value={filters.teamId || ""}
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
      {children}
    </BasicPage>
  )
}

export default TasksPage
