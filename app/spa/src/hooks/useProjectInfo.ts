import { gql, useQuery } from "@apollo/client"
import { projectMock } from "../lib/mocks"

export const QUERY = gql`
  query ProjectInfo($projectId: Int!) {
    project(id: $projectId) {
      id
      name
      currentRiskToDeadline
      remainingDays
      currentTeamBasedRisk
      running
      company {
        id
        name
        slug
      }
    }
  }
`

type ProjectInfo = {
  project: {
    id: number
    name: string
    currentRiskToDeadline: number
    remainingDays: number
    currentTeamBasedRisk: number
    running: boolean
    company: {
      id: string
      name: string
      slug: string
    }
  }
}

type ProjectInfoDTO = ProjectInfo | undefined

const useProjectInfo = (projectId: number) => {
  const { data, loading, error } = useQuery<ProjectInfoDTO>(QUERY, {
    variables: { projectId },
  })

  return { projectInfo: data?.project, loading, error }
}

export default useProjectInfo
