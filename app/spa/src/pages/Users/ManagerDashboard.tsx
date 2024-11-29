import ProjectBurnup from "../Projects/ProjectBurnup"
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
import { FormElement } from "../../components/ui/Form"
import SearchIcon from "@mui/icons-material/Search"
import { useForm } from "react-hook-form"
import { useSearchParams } from "react-router-dom"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { Project } from "../../modules/project/project.types"
import { PROJECT_STANDARD_FRAGMENT } from "../../components/ProjectPage"
import ActiveContractsHoursTicket from "../../modules/contracts/ActiveContractsHoursTicket"

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
      <Box sx={{ display: "flex" }}>
        <Box sx={{ width: "50%" }}>
          <Typography sx={{ fontSize: "34px", fontWeight: 400 }}>
            {`${loadedProject?.name} | Visão Geral`}
          </Typography>
        </Box>
        <Box sx={{ width: "50%" }}>
          <form>
            <FormGroup>
              <Grid container>
                <FormElement>
                  <InputLabel htmlFor="searchText">
                    {t("list.form.search")}
                  </InputLabel>
                  <Input
                    {...register("searchText")}
                    defaultValue={searchText}
                  />
                </FormElement>

                <FormElement>
                  <Button sx={{ alignSelf: "flex-start" }} type="submit">
                    <SearchIcon fontSize="large" color="primary" />
                  </Button>
                </FormElement>
              </Grid>
            </FormGroup>
          </form>
        </Box>
      </Box>
      {project ? (
        <Box sx={{ padding: 4 }}>
          <ActiveContractsHoursTicket project={project} />
          <Box sx={{ width: "50%" }}>
            <ProjectBurnup project={project} />
          </Box>
        </Box>
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

        totalActiveContractsHours
        consumedActiveContractsHours
        remainingActiveContractsHours

        demandsBurnup {
          scope
          xAxis
          idealBurn
          currentBurn
        }
      }
      projectsActive {
        ...ProjectStandardFragment

        demandsBurnup {
          scope
          xAxis
          idealBurn
          currentBurn
        }
      }
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

export default ManagerDashboard
