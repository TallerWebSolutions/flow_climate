import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useEffect } from "react"
import { useParams } from "react-router-dom"
import BasicPage from "../components/BasicPage"
import { Project } from "../components/ReplenishingProjectsInfo"
import TicketGroup from "../components/TicketGroup"

// TODO: cut this query to only necessary data
export const PROJECT_STATUS_REPORT_QUERY = gql`
  query ProjectStatusReport($id: Int!) {
    project(id: $id) {
      id
      name
      endDate
      firstDeadline
      daysDifferenceBetweenFirstAndLastDeadlines
      deadlinesChangeCount
      currentCost
      averageSpeed
      averageDemandAging
      totalThroughput
      failureLoad
      leadTimeP80

      weeklyThroughputs
      workInProgressLimit
      currentWeeksByLittleLaw
      # totalScope
      remainingBacklog
      totalHoursConsumed
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

type ProjectStatusReportResult = {
  project: Project
}

type ProjectStatusReportDTO = ProjectStatusReportResult | undefined

export const RiskDrill = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectStatusReportDTO>(
    PROJECT_STATUS_REPORT_QUERY,
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
      name: "Status Report",
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
      value: 2,
      unity: "demandas",
    },
    {
      title: "Backlog",
      value: data?.project.remainingBacklog,
      unity: "demandas",
    },
    {
      title: "Tempo decorrido",
      value: data?.project.totalHoursConsumed.toFixed(2),
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
      value: data?.project.monteCarloP80,
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: data?.project.currentMonteCarloWeeksStdDev,
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
      value: data?.project.teamMonteCarloP80,
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: data?.project.teamMonteCarloWeeksStdDev.toFixed(2),
      unity: "semanas",
    },
  ]

  return (
    <BasicPage
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
    </BasicPage>
  )
}

export default RiskDrill
