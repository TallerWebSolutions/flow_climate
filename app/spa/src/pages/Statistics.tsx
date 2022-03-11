import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useParams } from "react-router-dom"
import { ProjectPage } from "../components/ProjectPage"
import { Project } from "../components/ReplenishingProjectsInfo"

export const QUERY = gql`
  query ProjectStatistics($id: Int!) {
    project(id: $id) {
      id
      name
      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
      company {
        id
        name
        slug
      }
    }
  }
`

type ProjectStatisticsResult = {
  project: Project
}

type ProjectStatisticsDTO = ProjectStatisticsResult | undefined

const Statistics = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectStatisticsDTO>(QUERY, {
    variables: {
      id: Number(projectId),
    },
  })
  const project = data?.project!

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <ProjectPage pageName={"Statistics"} project={project}>
      <p>Statistics</p>
    </ProjectPage>
  )
}

export default Statistics
