import { ReactElement } from "react"
import { useLocation } from "react-router-dom"
import { Box } from "@mui/material"
import BasicPage from "./BasicPage"
import { Tab, Tabs } from "./Tabs"
import Card, { CardType } from "./Card"
import { Project } from "./ReplenishingProjectsInfo"
import { gql } from "@apollo/client"

export const PROJECT_STANDARD_FRAGMENT = gql`
  fragment ProjectStandardFragment on Project {
    id
    name
    company {
      id
      name
      slug
    }
  }
`

type ProjectPageProps = {
  tabs?: Tab[]
  pageName: string
  project: Project
  children: ReactElement | ReactElement[]
}

const assignCardTypeByRisk = (risk: number) => {
  if (risk > 0.5 && risk <= 0.7) {
    return CardType.WARNING
  } else if (risk > 0.7) {
    return CardType.ERROR
  }

  return CardType.SUCCESS
}

export const ProjectPage = ({
  project,
  pageName,
  children,
}: ProjectPageProps) => {
  const { pathname } = useLocation()
  const projectId = project.id
  const projectIsRugging = project.running
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

  const currentOperationalRisk = project.currentRiskToDeadline
  const currentRiskToDeadlinePercentage = (
    currentOperationalRisk * 100
  ).toFixed(2)
  const remainingDays = project.remainingDays
  const currentTeamRisk = project.currentTeamBasedRisk
  const currentTeamRiskPercentage = (currentTeamRisk * 100).toFixed(2)
  const cardTypeTeamRisk = assignCardTypeByRisk(currentTeamRisk)
  const cardTypeOperationalRisk = assignCardTypeByRisk(currentOperationalRisk)

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={company}
    >
      <>
        {projectIsRugging && (
          <Box sx={{ display: "flex", my: 2 }}>
            <Card
              style={{ width: "300px", marginRight: "20px" }}
              title="Risco Operacional"
              subtitle={`Faltam ${remainingDays} dia(s) para o fim do projeto e o risco operacional deste prazo é de ${currentRiskToDeadlinePercentage}%`}
              type={cardTypeOperationalRisk}
            />

            <Card
              style={{ width: "300px" }}
              title="Risco Atual"
              subtitle={`Com a estratégia de WiP e pelos dados do time, o risco atual é de ${currentTeamRiskPercentage}%`}
              type={cardTypeTeamRisk}
            />
          </Box>
        )}
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
