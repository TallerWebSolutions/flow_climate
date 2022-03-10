import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useParams } from "react-router-dom"
import { ProjectPage } from "../components/ProjectPage"
import { Project } from "../components/ReplenishingProjectsInfo"
import TicketGroup from "../components/TicketGroup"

export const PROJECT_RISK_DRILL_QUERY = gql`
  query ProjectRiskDrill($id: Int!) {
    project(id: $id) {
      name
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
      company {
        id
        name
        slug
      }
    }
  }
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

  const projectName = data?.project.name || ""
  const companyName = data?.project.company.name || ""
  const companySlug = data?.project.company.slug
  const breadcrumbsLinks = [
    { name: companyName, url: `/companies/${companySlug}` },
    { name: "Projetos", url: `/companies/${companySlug}/projects` },
    {
      name: projectName,
      url: `/companies/${companySlug}/projects/${data?.project.id}`,
    },
    {
      name: "Risk Drill",
    },
  ]
  const projectTabs = [
    {
      label: "Gráficos",
      to: `/companies/${companySlug}/projects/${projectId}`,
    },
    {
      label: "Estatísticas",
      to: `/companies/${companySlug}/projects/${projectId}/statistics_tab`,
    },
    {
      label: "Detalhamento do Risco",
      to: `/companies/${companySlug}/projects/${projectId}/risk_drill_down`,
    },
    {
      label: "Relatório de Status",
      to: `/companies/${companySlug}/projects/${projectId}/status_report_dashboard`,
    },
    {
      label: "Lead time dashboard",
      to: `/companies/${companySlug}/projects/${projectId}/lead_time_dashboard`,
    },
  ]

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
    <ProjectPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={data?.project.company}
      tabs={projectTabs}
    >
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
