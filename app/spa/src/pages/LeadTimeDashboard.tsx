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
    {
      label: "Lead time dashboard",
      to: `/companies/${companySlug}/projects/${projectId}/lead_time_dashboard`,
    },
  ]

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={data?.project.company}
      tabs={projectTabs}
    >
      <p>None</p>
    </BasicPage>
  )
}

export default LeadTimeDashboard
