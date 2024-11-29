import { gql, useQuery } from "@apollo/client"
import { Box } from "@mui/material"
import { useParams } from "react-router-dom"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../../components/ProjectPage"
import { Project } from "../../modules/project/project.types"
import ProjectBurnup from "./ProjectBurnup"
import ActiveContractsHoursTicket from "../../modules/contracts/ActiveContractsHoursTicket"

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
      <Box sx={{ padding: 4 }}>
        {project && <ActiveContractsHoursTicket project={project} />}

        <Box sx={{ width: "50%" }}>
          {project && <ProjectBurnup project={project} />}
        </Box>
      </Box>
    </ProjectPage>
  )
}

export default StatusReport
