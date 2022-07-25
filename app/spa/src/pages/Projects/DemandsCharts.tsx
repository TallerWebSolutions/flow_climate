import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useParams } from "react-router-dom"

import { PROJECT_STANDARD_FRAGMENT } from "../../components/ProjectPage"
import { Project } from "../../modules/project/project.types"
import ProjectDemandsCharts from "../../components/ProjectDemandsCharts"

const LIMIT_DEMANDS_PER_PAGE = 10

const PROJECT_CHART_QUERY = gql`
  query ProjectDemandsCharts($projectId: ID!) {
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
      projectMembers {
        demandsCount
        memberName
      }
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

      leadTimeHistogramData {
        keys
        values
      }

      demandsFlowChartData {
        creationChartData
        committedChartData
        pullTransactionRate
        throughputChartData
        xAxis
      }

      projectConsolidationsWeekly {
        leadTimeP80
        projectQuality
        consolidationDate
        operationalRisk
        tasksBasedOperationalRisk
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

      projectConsolidationsLastMonth {
        consolidationDate
        projectThroughputHoursInMonth
        projectThroughputHoursManagementInMonth
        projectThroughputHoursDevelopmentInMonth
        projectThroughputHoursDesignInMonth

        projectThroughputHoursManagement
        projectThroughputHoursDevelopment
        projectThroughputHoursDesign
      }

      lastProjectConsolidationsWeekly {
        leadTimeP65
        leadTimeP80
        leadTimeP95
      }

      demandsFinishedWithLeadtime {
        id
        leadtime
        externalId
      }

      hoursPerStageChartData {
        xAxis
        yAxis
      }

      leadTimeBreakdown {
        xAxis
        yAxis
      }

      cumulativeFlowChartData {
        xAxis
        yAxis {
          name
          data
        }
      }
      hoursBurnup {
        scope
        xAxis
        idealBurn
        currentBurn
      }
      tasksBurnup {
        scope
        xAxis
        idealBurn
        currentBurn
      }
      demandsBurnup {
        scope
        xAxis
        idealBurn
        currentBurn
      }
    }
    hoursPerCoordinationStageChartData: project(id: $projectId) {
      hoursPerStageChartData(stageLevel: "coordination") {
        xAxis
        yAxis
      }
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectChartResult = {
  project: Project
  hoursPerCoordinationStageChartData: Pick<Project, "hoursPerStageChartData">
}

type ProjectChartDTO = ProjectChartResult | undefined

const DemandsCharts = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectChartDTO>(PROJECT_CHART_QUERY, {
    variables: {
      projectId,
      limit: LIMIT_DEMANDS_PER_PAGE,
    },
  })

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const project = data?.project
  const hoursPerCoordinationStageChartData =
    data?.hoursPerCoordinationStageChartData.hoursPerStageChartData

  return project ? (
    <ProjectDemandsCharts
      project={project}
      hoursPerCoordinationStageChartData={hoursPerCoordinationStageChartData}
    />
  ) : (
    <>Project not found</>
  )
}

export default DemandsCharts
