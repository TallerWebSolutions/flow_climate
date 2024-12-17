import { gql, useQuery } from "@apollo/client"
import { Project } from "../modules/project/project.types"

export const PROJECT_QUERY = gql`
  query ProjectInfo($projectId: ID!) {
    project(id: $projectId) {
      id
      name
      currentRiskToDeadline
      remainingDays
      currentTeamBasedRisk
      running
      endDate
      company {
        id
        name
        slug
      }
    }
  }
`

type ProjectInfoDTO = {
  project?: Project
}

const useProjectInfo = (projectId: string) => {
  const { data, loading, error } = useQuery<ProjectInfoDTO>(PROJECT_QUERY, {
    variables: { projectId },
  })

  return { projectInfo: data?.project, loading, error }
}

export default useProjectInfo
