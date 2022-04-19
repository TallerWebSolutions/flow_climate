import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { ProjectChartsTable } from "../components/ProjectChartsTable"
import { ProjectPage, PROJECT_STANDARD_FRAGMENT } from "../components/ProjectPage"
import { Demand } from "../modules/demand/demand.types"
import { Project } from "../modules/project/project.types"

const LIMIT_DEMANDS_PER_PAGE = 10

export const PROJECT_CHART_QUERY = gql`
  query ProjectCharts($projectId: Int!, $limit: Int!) {
    project(id: $projectId) {
      ...ProjectStandardFragment
      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running

      startDate
      endDate
      initialScope
      numberOfDemands
      numberOfDemandsDelivered
      remainingBacklog
      upstreamDemands {
        id
      }
      numberOfDownstreamDemands
      discardedDemands {
        id
      }
      unscoredDemands {
        id
      }
      demandBlocks {
        id
      }
      flowPressure
      averageSpeed
      averageQueueTime
      averageTouchTime
      leadTimeP65
      leadTimeP80
      leadTimeP95
    }

    demands(projectId: $projectId, limit: $limit, finished: true) {
      id
      endDate
      product {
        id
        name
      }
      customer {
        id
        name
      }
      externalId
      leadtime
      numberOfBlocks
    }    
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectChartResult = {
  project: Project
  demands: Demand[]
}

type ProjectChartDTO = ProjectChartResult | undefined

const ProjectsChart = () => {  
  const { t } = useTranslation(["projectChart"])
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectChartDTO>(
    PROJECT_CHART_QUERY,
    {
      variables: {
        projectId: Number(projectId),
        limit: LIMIT_DEMANDS_PER_PAGE,
      },
    }
  )

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const project = data?.project!
  const demands = data?.demands!

  return (
    <ProjectPage pageName={t('charts')} project={project}>
      <ProjectChartsTable project={project} demands={demands} />
    </ProjectPage>
  )
}

export default ProjectsChart