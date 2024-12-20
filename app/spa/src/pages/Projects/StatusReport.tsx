import { gql, useQuery } from "@apollo/client"
import { Box } from "@mui/material"
import { useParams } from "react-router-dom"
import {
  PROJECT_STANDARD_FRAGMENT,
  ProjectPage,
} from "../../components/Projects/ProjectPage"
import { Project } from "../../modules/project/project.types"
import ActiveContractsHoursTicket from "../../modules/contracts/ActiveContractsHoursTicket"
import ProjectStatusReportCharts from "./Charts/ProjectStatusReportCharts"

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
          <Box sx={{ padding: 4 }}>
            <Box sx={{ width: "50%", marginBottom: 6 }}>
              <ActiveContractsHoursTicket project={project} />
            </Box>
            <ProjectStatusReportCharts project={project} />
          </Box>
        )}
      </>
    </ProjectPage>
  )
}

export const QUERY = gql`
  query ProjectStatusReport($id: ID!) {
    project(id: $id) {
      ...ProjectStandardFragment
      totalActiveContractsHours
      consumedActiveContractsHours
      remainingActiveContractsHours

      cumulativeFlowChartData {
        xAxis
        yAxis {
          name
          data
        }
      }

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

      demandsFinishedWithLeadtime {
        id
        leadtime
        externalId
        classOfService
      }
      lastProjectConsolidationsWeekly {
        leadTimeP65
        leadTimeP80
        leadTimeP95
      }
      projectConsolidationsWeekly {
        leadTimeP80
        projectQuality
        consolidationDate
        operationalRisk
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
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectStatusReportDTO = {
  project?: Project
}

export default StatusReport
