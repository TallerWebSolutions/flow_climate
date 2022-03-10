import { ReactElement } from "react"
import { useLocation } from "react-router-dom"
import { Box } from "@mui/material"
import BasicPage from "./BasicPage"
import { Tab, Tabs } from "./Tabs"
import Card, { CardType } from "./Card"
import { Project } from "./ReplenishingProjectsInfo"

type ProjectPageProps = {
  tabs?: Tab[]
  pageName: string
  project: Project
  children: ReactElement | ReactElement[]
}

export const ProjectPage = ({
  project,
  pageName,
  children,
}: ProjectPageProps) => {
  const { pathname } = useLocation()
  const projectId = project.id
  const projectName = project.name || ""
  const company = project.company || ""
  const companyName = company.name || ""
  const companySlug = company.slug
  const breadcrumbsLinks = [
    { name: companyName, url: `/companies/${companySlug}` },
    { name: "Projetos", url: `/companies/${companySlug}/projects` },
    {
      name: projectName,
      url: `/companies/${companySlug}/projects/${project.id}`,
    },
    {
      name: pageName,
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
      company={company}
    >
      <>
        <Card
          title="Risco Operacional"
          subtitle="Faltam 86 dia(s) para o fim do projeto e o risco operacional deste prazo é de 92,60%"
          type={CardType.WARNING}
        />

        <Card
          title="Risco Atual"
          subtitle="Com a estratégia de WiP e pelos dados do time, o risco atual é de 52,00%"
          type={CardType.SUCCESS}
        />
        {projectTabs && (
          <Box
            sx={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <Tabs tabs={projectTabs} currentPath={pathname} />
          </Box>
        )}
        {children}
      </>
    </BasicPage>
  )
}
