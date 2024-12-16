import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"
import {
  PROJECT_STANDARD_FRAGMENT,
  ProjectPage,
} from "../../components/Projects/ProjectPage"
import TicketGroup from "../../components/TicketGroup"
import { Project } from "../../modules/project/project.types"
import ProjectRiskSimulation from "../../modules/project/components/ProjectRiskSimulation"
import ProjectMonteCarloData from "../../modules/project/components/ProjectMonteCarloData"
import ProjectMonteCarloTeamData from "../../modules/project/components/ProjectMonteCarloTeamData"

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

  return (
    <ProjectPage pageName={"Risk Drill"} loading={loading}>
      {project && (
        <>
          <ProjectRiskSimulation project={project} />

          <TicketGroup
            title="Fluxo das últimas 10 semanas"
            data={flowLastFewWeeks}
          />
          <TicketGroup title="Escopo e prazo" data={scopeAndDeadline} />

          <ProjectMonteCarloData project={project} />
          <ProjectMonteCarloTeamData
            teamMonteCarloWeeksMin={project.teamMonteCarloWeeksMin || 0}
            teamMonteCarloWeeksMax={project.teamMonteCarloWeeksMax || 0}
            teamMonteCarloP80={project.teamMonteCarloP80 || 0}
            teamMonteCarloWeeksStdDev={project.teamMonteCarloWeeksStdDev || 0}
          />
        </>
      )}
    </ProjectPage>
  )
}

const PROJECT_RISK_DRILL_QUERY = gql`
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
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectRiskDrillDTO = {
  project?: Project
}

export default RiskDrill
