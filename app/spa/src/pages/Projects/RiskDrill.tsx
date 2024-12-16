import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"
import {
  PROJECT_STANDARD_FRAGMENT,
  ProjectPage,
} from "../../components/Projects/ProjectPage"
import TicketGroup from "../../components/TicketGroup"
import { Project } from "../../modules/project/project.types"
import ProjectRiskSimulation from "../../modules/project/components/ProjectRiskSimulation"

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

  const project = data?.project
  const flowLastFewWeeks = [
    {
      title: "Vazão",
      value: project?.weeklyThroughputs,
      unity: "Itens/semana",
    },
    {
      title: "Limite do WiP",
      value: project?.maxWorkInProgress,
      unity: "demandas",
    },
    {
      title: "Lei de Little",
      value: project?.currentWeeksByLittleLaw?.toFixed(2),
      unity: "semanas",
    },
  ]

  const scopeAndDeadline = [
    {
      title: "Escopo",
      value: project?.backlogCountFor,
      unity: "demandas",
    },
    {
      title: "Backlog",
      value: project?.remainingWork,
      unity: "demandas",
    },
    {
      title: "Tempo decorrido",
      value: project?.pastWeeks,
      unity: "semanas",
    },
    {
      title: "Tempo restante",
      value: project?.remainingWeeks,
      unity: "semanas",
    },
  ]

  const monteCarloProject = [
    {
      title: "Mínimo",
      value: project?.currentMonteCarloWeeksMin,
      unity: "semanas",
    },
    {
      title: "Máximo",
      value: project?.currentMonteCarloWeeksMax,
      unity: "semanas",
    },
    {
      title: "Percentil 80",
      value: project?.monteCarloP80?.toFixed(2),
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: project?.currentMonteCarloWeeksStdDev?.toFixed(2),
      unity: "semanas",
    },
  ]

  const monteCarloTeam = [
    {
      title: "Mínimo",
      value: project?.teamMonteCarloWeeksMin,
      unity: "semanas",
    },
    {
      title: "Máximo",
      value: project?.teamMonteCarloWeeksMax,
      unity: "semanas",
    },
    {
      title: "Percentil 80",
      value: project?.teamMonteCarloP80?.toFixed(2),
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: project?.teamMonteCarloWeeksStdDev?.toFixed(2),
      unity: "semanas",
    },
  ]

  return (
    <ProjectPage pageName={"Risk Drill"} loading={loading}>
      {project && <ProjectRiskSimulation project={project} />}
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

export const PROJECT_RISK_DRILL_QUERY = gql`
  query ProjectRiskDrill($id: ID!) {
    project(id: $id) {
      ...ProjectStandardFragment

      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
      weeklyThroughputs
      maxWorkInProgress
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

      projectSimulation {
        id
        weeklyThroughputs
      }
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectRiskDrillDTO = {
  project?: Project
}

export default RiskDrill
