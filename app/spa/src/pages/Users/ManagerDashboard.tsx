import { useContext } from "react"
import { MeContext } from "../../contexts/MeContext"
import {
  Box,
  Button,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Typography,
} from "@mui/material"
import BasicPage from "../../components/BasicPage"
import SearchIcon from "@mui/icons-material/Search"
import { useForm } from "react-hook-form"
import { useSearchParams } from "react-router-dom"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { Project } from "../../modules/project/project.types"
import ActiveContractsHoursTicket from "../../modules/contracts/ActiveContractsHoursTicket"
import { PROJECT_STANDARD_FRAGMENT } from "../../components/Projects/ProjectPage"
import ProjectStatusReportCharts from "../Projects/Charts/ProjectStatusReportCharts"

const ManagerDashboard = () => {
  const { me } = useContext(MeContext)
  const { register } = useForm()
  const { t } = useTranslation("demand")
  const { t: tProject } = useTranslation("projects")

  const [searchParams] = useSearchParams()

  const searchText = searchParams.get("searchText")

  const { data, loading } = useQuery<MANAGER_DASHBOARD_DTO>(
    MANAGER_DASHBOARD_QUERY,
    {
      variables: { name: searchText || "" },
    }
  )

  const projects = data?.me?.projects || []
  const loadedProject = projects[0]
  const project = loadedProject || me?.projectsActive?.[0]

  return (
    <BasicPage title={""} loading={loading}>
      {project ? (
        <>
          <Box sx={{ display: "flex" }}>
            <Box sx={{ width: "50%", paddingX: 4 }}>
              <Typography variant={"h4"}>
                {`${project?.name} | Visão Geral`}
              </Typography>
            </Box>
            <Box sx={{ width: "50%" }}>
              <form>
                <FormGroup style={{ width: "100%" }}>
                  <Grid container spacing={2} alignItems="center">
                    <Grid item xs={10}>
                      <InputLabel htmlFor="searchText">
                        {t("list.form.search")}
                      </InputLabel>
                      <Input
                        {...register("searchText")}
                        defaultValue={searchText}
                        fullWidth
                      />
                    </Grid>

                    <Grid item xs={2}>
                      <Button type="submit">
                        <SearchIcon fontSize="large" color="primary" />
                      </Button>
                    </Grid>
                  </Grid>
                </FormGroup>
              </form>
            </Box>
          </Box>
          <Box sx={{ padding: 4 }}>
            <Box sx={{ width: "50%", marginBottom: 4 }}>
              <ActiveContractsHoursTicket project={project} />
            </Box>
            <ProjectStatusReportCharts project={project} />
          </Box>
        </>
      ) : (
        <Typography>{tProject("projectsTable.emptyProjects")}</Typography>
      )}
    </BasicPage>
  )
}

type MANAGER_DASHBOARD_DTO = {
  me: {
    projects: Project[]
  }
}

const MANAGER_DASHBOARD_QUERY = gql`
  query ManagerDashboard($name: String) {
    me {
      projects(name: $name) {
        ...ProjectStandardFragment
        ...ProjectChartsFragment
        totalActiveContractsHours
        consumedActiveContractsHours
        remainingActiveContractsHours
      }
      projectsActive {
        ...ProjectStandardFragment
        ...ProjectChartsFragment
      }
    }
  }

  fragment ProjectChartsFragment on Project {
    demandsBurnup {
      scope
      xAxis
      idealBurn
      currentBurn
    }

    hoursBurnup {
      scope
      xAxis
      idealBurn
      currentBurn
    }
    demandsFinishedWithLeadtime {
      id
      leadtime
      externalId
    }
    lastProjectConsolidationsWeekly {
      leadTimeP65
      leadTimeP80
      leadTimeP95
    }
    projectConsolidationsWeekly {
      leadTimeP80
      projectQuality
      consolidationDate
      operationalRisk
      codeNeededBlocksCount
      codeNeededBlocksPerDemand
      flowEfficiency
      hoursPerDemand
      projectThroughput
      projectThroughputHours
      projectThroughputHoursAdditional
      bugsOpened
      bugsClosed
      projectThroughputHoursManagement
      projectThroughputHoursDevelopment
      projectThroughputHoursDesign
      projectThroughputHoursUpstream
      projectThroughputHoursDownstream
    }
    cumulativeFlowChartData {
      xAxis
      yAxis {
        name
        data
      }
    }
  }

  ${PROJECT_STANDARD_FRAGMENT}
`

export default ManagerDashboard
