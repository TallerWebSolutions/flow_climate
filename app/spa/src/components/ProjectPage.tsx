import { gql, useMutation } from "@apollo/client"
import { Box } from "@mui/material"
import { ReactElement, useContext } from "react"
import { useTranslation } from "react-i18next"
import { useLocation } from "react-router-dom"
import { MessagesContext } from "../contexts/MessageContext"
import { Project } from "../modules/project/project.types"
import BasicPage from "./BasicPage"
import Card, { CardType } from "./Card"
import ActionMenu from "./menu/ActionMenu"
import { Tab, Tabs } from "./Tabs"

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

const GENERATE_PROJECT_MUTATION = gql`
  mutation GenerateProjectCache($projectId: String!) {
    generateProjectCache(projectId: $projectId) {
      statusMessage
    }
  }
`

type ProjectCacheResult = {
  generateProjectCache: {
    statusMessage: string
  }
}

type ProjectCacheDTO = ProjectCacheResult | undefined

export const ProjectPage = ({
  project,
  pageName,
  children,
}: ProjectPageProps) => {
  const { pathname } = useLocation()
  const { t } = useTranslation(["generalProjectPage"])
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
      url: `/companies/${companySlug}/projects/${projectId}`,
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
  const { pushMessage } = useContext(MessagesContext)
  const [generateProjectCache] = useMutation<ProjectCacheDTO>(
    GENERATE_PROJECT_MUTATION,
    {
      update: () =>
        pushMessage({
          text: "Sua solicitação foi colocada na fila. Em poucos minutos estará pronta.",
          severity: "info",
        }),
    }
  )

  const actions = [
    {
      name: "Atualizar Cache",
      onClick: () =>
        generateProjectCache({
          variables: { projectId: project.id },
        }),
    },
    {
      name: "Criar Demanda",
      href: `/companies/${companySlug}/projects/${projectId}/demands/new`,
    },
    {
      name: "Editar",
      href: `/companies/${companySlug}/projects/${projectId}/edit`,
    },
    {
      name: "Configuração do Jira",
      href: `/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs`,
    },
    {
      name: "Etapas no Projeto",
      href: `/companies/${companySlug}/projects/${projectId}/stage_project_configs`,
    },
    {
      name: "Configuração de Risco",
      href: `/companies/${companySlug}/projects/${projectId}/project_risk_configs`,
    },
  ]

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={company}
      actions={<ActionMenu items={actions} />}
    >
      <>
        {projectIsRugging && (
          <Box sx={{ display: "flex", my: 2 }}>
            <Card
              style={{ width: "350px", marginRight: "20px" }}
              title={t("cards.operational_risk")}
              subtitle={t("cards.operational_risk_message", {
                days: remainingDays,
                percentage: currentRiskToDeadlinePercentage,
              })}
              type={cardTypeOperationalRisk}
            />

            <Card
              style={{ width: "350px" }}
              title={t("cards.operational_risk_team_data")}
              subtitle={t("cards.operational_risk_team_data_message", {
                risk: currentTeamRiskPercentage,
              })}
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
