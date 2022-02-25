import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"
import BasicPage from "../components/BasicPage"
import { Project } from "../components/ReplenishingProjectsInfo"

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
      totalHoursConsumed
      averageSpeed
      averageDemandAging
      totalThroughput
      remainingBacklog
      failureLoad
      leadTimeP80
      weeklyThroughputs
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
  const { data, loading, error } = useQuery<ProjectStatusReportDTO>(
    PROJECT_STATUS_REPORT_QUERY,
    {
      variables: {
        id: Number(projectId),
      },
    }
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

  

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      tabs={projectTabs}
    >
      <p>teste</p>
    </BasicPage>
  )
}

export default RiskDrill
