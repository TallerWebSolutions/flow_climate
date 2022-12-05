import { gql, useQuery } from "@apollo/client"

export const PROJECT_QUERY = gql`
  query ProjectInfo($projectId: ID!) {
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

const useProjectInfo = (projectId: string) => {
  const { data, loading, error } = useQuery<ProjectInfoDTO>(PROJECT_QUERY, {
    variables: { projectId },
  })

  return { projectInfo: data?.project, loading, error }
}

export default useProjectInfo
