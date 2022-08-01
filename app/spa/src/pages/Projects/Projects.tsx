import { useContext, useState, useCallback, ChangeEvent } from "react"
import { MeContext } from "../../contexts/MeContext"
import {
  Button,
  Box,
  TextField,
  Select,
  SelectChangeEvent,
  FormControl,
  InputLabel,
  MenuItem,
  TextFieldProps,
} from "@mui/material"
import LocalizationProvider from "@mui/lab/LocalizationProvider"
import AdapterDateFns from "@mui/lab/AdapterDateFns"
import SearchIcon from "@mui/icons-material/Search"
import DatePicker from "@mui/lab/DatePicker"
import BasicPage from "../../components/BasicPage"
import { useTranslation } from "react-i18next"
import { toISOFormat } from "../../lib/date"
import ProjectsList from "./List"

export type ProjectsFilters = {
  name?: string
  status?: string
  startDate?: string | null
  endDate?: string | null
}

const ProjectList = () => {
  const { t } = useTranslation(["projects"])
  const { me } = useContext(MeContext)
  const [projectSearchName, setProjectSearchName] = useState("")
  const [startDate, setStartDate] = useState<string | null>(null)
  const [endDate, setEndDate] = useState<string | null>(null)
  const [projectsFilters, setProjectsFilters] = useState<ProjectsFilters>({
    status: "",
  })

  const handleSearchByName = useCallback(
    (event: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
      setProjectSearchName(String(event.target.value)),
    []
  )

  const handleStatus = (event: SelectChangeEvent<any>) => {
    const status = event.target.value
    setProjectsFilters((prevState) => ({ ...prevState, status }))
  }

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const createNewProjectUrl = `${companyUrl}/projects/new`

  const breadcrumbsLinks = [
    { name: "Home", url: "/" },
    { name: me?.currentCompany?.name || "", url: companyUrl },
    { name: t("projects") },
  ]

  const handleRefectSearch = () => {
    const startDateISO = startDate ? toISOFormat(startDate) : null
    const endDateISO = endDate ? toISOFormat(endDate) : null
    setProjectsFilters((prevState) => ({
      ...prevState,
      name: projectSearchName,
      startDate: startDateISO,
      endDate: endDateISO,
    }))
  }

  return (
    <BasicPage title={t("projects")} breadcrumbsLinks={breadcrumbsLinks}>
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
            <DatePicker
              label={t("filter.initial_date")}
              value={startDate}
              onChange={setStartDate}
              renderInput={(params: TextFieldProps) => (
                <TextField {...params} />
              )}
            />
            <DatePicker
              label={t("filter.end_date")}
              value={endDate}
              onChange={setEndDate}
              renderInput={(params: TextFieldProps) => (
                <TextField {...params} />
              )}
            />
            <FormControl fullWidth>
              <InputLabel id="status-filter">{t("filter.status")}</InputLabel>
              <Select
                labelId="status-filter"
                label={t("filter.status")}
                value={projectsFilters.status}
                onChange={(event) => handleStatus(event)}
              >
                <MenuItem value="">{t("filter.status")}</MenuItem>
                <MenuItem value="waiting">
                  {t("filter.status_waiting")}
                </MenuItem>
                <MenuItem value="executing">
                  {t("filter.status_executing")}
                </MenuItem>
                <MenuItem value="maintenance">
                  {t("filter.status_maintenance")}
                </MenuItem>
                <MenuItem value="finished">
                  {t("filter.status_finished")}
                </MenuItem>
                <MenuItem value="cancelled">
                  {t("filter.status_cancelled")}
                </MenuItem>
                <MenuItem value="negotiating">
                  {t("filter.status_negotiating")}
                </MenuItem>
              </Select>
            </FormControl>

            <TextField
              value={projectSearchName}
              onChange={handleSearchByName}
              label={t("filter.search")}
              helperText={t("filter.search_helper")}
              sx={{ gridRow: 2, gridColumn: "1 / 3" }}
            />

            <Button
              onClick={handleRefectSearch}
              sx={{ width: "60px", height: "55px", gridRow: 2 }}
            >
              <SearchIcon fontSize="large" color="primary" />
            </Button>
          </Box>
        </LocalizationProvider>
      </Box>
      <Button
        variant="contained"
        href={createNewProjectUrl}
        sx={{ float: "right", marginBottom: "2rem" }}
      >
        New Project
      </Button>

      <ProjectsList filters={projectsFilters} setFilters={setProjectsFilters} />
    </BasicPage>
  )
}

export default ProjectList
