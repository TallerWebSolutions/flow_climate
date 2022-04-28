import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useParams } from "react-router-dom"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../components/ProjectPage"
import TicketGroup from "../components/TicketGroup"
import { secondsToReadbleDate } from "../lib/date"
import { Project } from "../modules/project/project.types"

export const LEAD_TIME_DASHBOARD_QUERY = gql`
  query ProjectLeadTimeDashboard($id: Int!) {
    project(id: $id) {
      ...ProjectStandardFragment

      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
      projectConsolidations {
        leadTimeMin
        leadTimeMax
        leadTimeP80
        leadTimeFeature
        leadTimeBug
        leadTimeChore
        leadTimeStandard
        leadTimeFixedDate
        leadTimeExpedite
        leadTimeStdDev
        leadTimeAverage
        demandsFinishedIds
        leadTimeHistogramBinMin
        leadTimeHistogramBinMax
      }
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectLeadTimeDashboardResult = {
  project: Project
}

type ProjectLeadTimeDashboardDTO = ProjectLeadTimeDashboardResult | undefined

const LeadTimeDashboard = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectLeadTimeDashboardDTO>(
    LEAD_TIME_DASHBOARD_QUERY,
    {
      variables: {
        id: Number(projectId),
      },
    }
  )

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const lastProjectConsolidation = data?.project.projectConsolidations.pop()

  const currentLeadTime = [
    {
      title: "Mínimo",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeMin!),
    },
    {
      title: "Máximo",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeMax!),
    },
    {
      title: "Percentil 80",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeP80!),
    },
    {
      title: "Desvio padrão",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeStdDev!),
    },
    {
      title: "Bin mínimo do histograma",
      value: secondsToReadbleDate(
        lastProjectConsolidation?.leadTimeHistogramBinMin!
      ),
    },
    {
      title: "Bin máximo do histograma",
      value: secondsToReadbleDate(
        lastProjectConsolidation?.leadTimeHistogramBinMax!
      ),
    },
    {
      title: "Média",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeAverage!),
    },
    {
      title: "Tamanho da amostra",
      value: lastProjectConsolidation?.demandsFinishedIds.length,
      unity: "demandas",
    },
  ]

  const currentLeadTimeByType = [
    {
      title: "Nova funcionalidade",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeFeature!),
    },
    {
      title: "Bug",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeBug!),
    },
    {
      title: "Chore",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeChore!),
    },
  ]

  const currentLeadTimeByServiceClass = [
    {
      title: "Padrão",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeStandard!),
    },
    {
      title: "Data fixa",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeFixedDate!),
    },
    {
      title: "Expedição",
      value: secondsToReadbleDate(lastProjectConsolidation?.leadTimeExpedite!),
    },
  ]

  return (
    <ProjectPage pageName={"Lead Time Dashboard"}>
      <TicketGroup title="Leadtime" data={currentLeadTime} />
      <TicketGroup
        title="Leadtime por tipo - 80%"
        data={currentLeadTimeByType}
      />
      <TicketGroup
        title="Leadtime por classe de serviço - 80%"
        data={currentLeadTimeByServiceClass}
      />
    </ProjectPage>
  )
}

export default LeadTimeDashboard
