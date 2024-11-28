import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../../components/ProjectPage"
import { Project } from "../../modules/project/project.types"
import ProjectBurnup from "./ProjectBurnup"

export const QUERY = gql`
  query ProjectStatusReport($id: ID!) {
    project(id: $id) {
      ...ProjectStandardFragment

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
      <>{project && <ProjectBurnup project={project} />}</>
    </ProjectPage>
  )
}

export default StatusReport
