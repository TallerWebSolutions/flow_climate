import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"
import { useParams } from "react-router-dom"
import BasicPage from "../components/BasicPage"
import { Project } from "../components/ReplenishingProjectsInfo"
import TicketGroup from "../components/TicketGroup"

export const LEAD_TIME_DASHBOARD_QUERY = gql`
  query ProjectLeadTimeDashboard($id: Int!) {
    project(id: $id) {
      name
      company {
        id
        name
        slug
      }

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
      name: "Lead Time Dashboard",
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

  const currentLeadTime = [
    {
      title: "Mínimo",
      value: lastProjectConsolidation?.leadTimeMin,
    },
    {
      title: "Máximo",
      value: lastProjectConsolidation?.leadTimeMax,
    },
    {
      title: "Percentil 80",
      value: lastProjectConsolidation?.leadTimeP80,
    },
    {
      title: "Desvio padrão",
      value: lastProjectConsolidation?.leadTimeStdDev,
    },
    {
      title: "Bin mínimo do histograma",
      value: lastProjectConsolidation?.leadTimeHistogramBinMin,
    },
    {
      title: "Bin máximo do histograma ",
      value: lastProjectConsolidation?.leadTimeHistogramBinMax,
    },
    {
      title: "Média",
      value: lastProjectConsolidation?.leadTimeAverage,
    },
    {
      title: "Tamanho da amostra",
      value: lastProjectConsolidation?.demandsFinishedIds.length,
    },
  ]

  const currentLeadTimeByType = [
    {
      title: "Nova funcionalidade",
      value: lastProjectConsolidation?.leadTimeFeature,
    },
    {
      title: "Bug",
      value: lastProjectConsolidation?.leadTimeBug,
    },
    {
      title: "Chore",
      value: lastProjectConsolidation?.leadTimeChore,
    },
  ]

  const currentLeadTimeByServiceClass = [
    {
      title: "Padrão",
      value: lastProjectConsolidation?.leadTimeStandard,
    },
    {
      title: "Data fixa",
      value: lastProjectConsolidation?.leadTimeFixedDate,
    },
    {
      title: "Expedição",
      value: lastProjectConsolidation?.leadTimeExpedite,
    },
  ]

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={data?.project.company}
      tabs={projectTabs}
    >
      <TicketGroup title="Leadtime" data={currentLeadTime} />
      <TicketGroup
        title="Leadtime por tipo - 80%"
        data={currentLeadTimeByType}
      />
      <TicketGroup
        title="Leadtime por classe de serviço - 80%"
        data={currentLeadTimeByServiceClass}
      />
    </BasicPage>
  )
}

export default LeadTimeDashboard
