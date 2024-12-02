import { gql, useQuery } from "@apollo/client"
import { Box } from "@mui/material"
import { useParams } from "react-router-dom"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../../components/Projects/ProjectPage"
import { Project } from "../../modules/project/project.types"
import ActiveContractsHoursTicket from "../../modules/contracts/ActiveContractsHoursTicket"
import ProjectBurnup from "./Charts/ProjectBurnup"
import ProjectHoursBurnup from "./Charts/ProjectHoursBurnup"

export const QUERY = gql`
  query ProjectStatusReport($id: ID!) {
    project(id: $id) {
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

      hoursBurnup {
        scope
        xAxis
        idealBurn
        currentBurn
      }
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectStatusReportResult = {
  project: Project
}

type ProjectStatusReportDTO = ProjectStatusReportResult | undefined

const StatusReport = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectStatusReportDTO>(QUERY, {
    variables: {
      id: Number(projectId),
    },
  })

  const project = data?.project

  return (
    <ProjectPage pageName={"Status Report"} loading={loading}>
      <>
        {project && (
          <Box sx={{ padding: 4, gap: 4 }}>
            <Box sx={{ width: "50%" }}>
              <ActiveContractsHoursTicket project={project} />
            </Box>
            <Box sx={{ display: "flex" }}>
              <Box sx={{ width: "50%" }}>
                <ProjectBurnup project={project} />
              </Box>
              <Box sx={{ width: "50%" }}>
                <ProjectHoursBurnup project={project} />
              </Box>
            </Box>
          </Box>
        )}
      </>
    </ProjectPage>
  )
}

export default StatusReport
