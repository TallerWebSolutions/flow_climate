import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useParams } from "react-router-dom"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../components/ProjectPage"
import TicketGroup from "../components/TicketGroup"
import { Project } from "../modules/project/project.types"

export const PROJECT_RISK_DRILL_QUERY = gql`
  query ProjectRiskDrill($id: Int!) {
    project(id: $id) {
      ...ProjectStandardFragment

      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
      weeklyThroughputs
      workInProgressLimit
      currentWeeksByLittleLaw
      backlogCountFor
      remainingWork
      pastWeeks
      remainingWeeks
      monteCarloP80
      currentMonteCarloWeeksMin
      currentMonteCarloWeeksMax
      currentMonteCarloWeeksStdDev
      teamMonteCarloP80
      teamMonteCarloWeeksMin
      teamMonteCarloWeeksMax
      teamMonteCarloWeeksStdDev
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectRiskDrillResult = {
  project: Project
}

type ProjectRiskDrillDTO = ProjectRiskDrillResult | undefined

export const RiskDrill = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectRiskDrillDTO>(
    PROJECT_RISK_DRILL_QUERY,
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

  const project = data?.project!
  const flowLastFewWeeks = [
    {
      title: "Vazão",
      value: data?.project.weeklyThroughputs,
      unity: "Itens/semana",
    },
    {
      title: "Limite do WiP",
      value: data?.project.workInProgressLimit,
      unity: "demandas",
    },
    {
      title: "Lei de Little",
      value: data?.project.currentWeeksByLittleLaw?.toFixed(2),
      unity: "semanas",
    },
  ]

  const scopeAndDeadline = [
    {
      title: "Escopo",
      value: data?.project.backlogCountFor,
      unity: "demandas",
    },
    {
      title: "Backlog",
      value: data?.project.remainingWork,
      unity: "demandas",
    },
    {
      title: "Tempo decorrido",
      value: data?.project.pastWeeks,
      unity: "semanas",
    },
    {
      title: "Tempo restante",
      value: data?.project.remainingWeeks,
      unity: "semanas",
    },
  ]

  const monteCarloProject = [
    {
      title: "Mínimo",
      value: data?.project.currentMonteCarloWeeksMin,
      unity: "semanas",
    },
    {
      title: "Máximo",
      value: data?.project.currentMonteCarloWeeksMax,
      unity: "semanas",
    },
    {
      title: "Percentil 80",
      value: data?.project.monteCarloP80.toFixed(2),
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: data?.project.currentMonteCarloWeeksStdDev.toFixed(2),
      unity: "semanas",
    },
  ]

  const monteCarloTeam = [
    {
      title: "Mínimo",
      value: data?.project.teamMonteCarloWeeksMin,
      unity: "semanas",
    },
    {
      title: "Máximo",
      value: data?.project.teamMonteCarloWeeksMax,
      unity: "semanas",
    },
    {
      title: "Percentil 80",
      value: data?.project.teamMonteCarloP80.toFixed(2),
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: data?.project.teamMonteCarloWeeksStdDev.toFixed(2),
      unity: "semanas",
    },
  ]

  return (
    <ProjectPage pageName={"Risk Drill"}>
      <TicketGroup
        title="Fluxo das últimas 10 semanas"
        data={flowLastFewWeeks}
      />
      <TicketGroup title="Escopo e prazo" data={scopeAndDeadline} />
      <TicketGroup title="Monte Carlo (Projeto)" data={monteCarloProject} />
      <TicketGroup title="Monte Carlo (Time)" data={monteCarloTeam} />
    </ProjectPage>
  )
}

export default RiskDrill
