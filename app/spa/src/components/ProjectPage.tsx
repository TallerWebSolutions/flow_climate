import { gql, useMutation } from "@apollo/client"
import { Box } from "@mui/material"
import { ReactElement, useContext } from "react"
import { useTranslation } from "react-i18next"
import { useLocation, useParams } from "react-router-dom"
import { MessagesContext } from "../contexts/MessageContext"
import useProjectInfo from "../hooks/useProjectInfo"
import BasicPage from "./BasicPage"
import Card, { CardType } from "./Card"
import ActionMenu from "./menu/ActionMenu"
import { Tabs } from "./Tabs"

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
  pageName: string
  children: ReactElement | ReactElement[]
  loading?: boolean
  dashboard?: boolean
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
  mutation GenerateProjectCache($projectId: ID!) {
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
  pageName,
  children,
  loading,
  dashboard = false,
}: ProjectPageProps) => {
  const { pathname } = useLocation()
  const { t } = useTranslation(["generalProjectPage"])
  const { pushMessage } = useContext(MessagesContext)
  const [generateProjectCache] = useMutation<ProjectCacheDTO>(
    GENERATE_PROJECT_MUTATION,
    {
      update: () =>
        pushMessage({
          text: t("flash_message.token_generetaed_with_success"),
          severity: "info",
        }),
    }
  )
  const params = useParams()
  const projectId = params.projectId || ""
  const { projectInfo, loading: queryLoading } = useProjectInfo(projectId)

  if (!projectInfo && !queryLoading) return <strong>No project found</strong>

  const projectIsRunning = projectInfo?.running
  const projectName = projectInfo?.name || ""
  const company = projectInfo?.company
  const companyName = company?.name || ""
  const companySlug = company?.slug
  const breadcrumbsLinks = [
    { name: companyName, url: `/companies/${companySlug}` },
    {
      name: t("breadcrumbs_links.projects"),
      url: `/companies/${companySlug}/projects`,
    },
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
      label: t("breadcrumbs_links.charts"),
      to: `/companies/${companySlug}/projects/${projectId}`,
    },
    {
      label: t("breadcrumbs_links.statistics"),
      to: `/companies/${companySlug}/projects/${projectId}/statistics_tab`,
    },
    {
      label: t("breadcrumbs_links.risk_drill_down"),
      to: `/companies/${companySlug}/projects/${projectId}/risk_drill_down`,
    },
    {
      label: t("breadcrumbs_links.status_report_dashboard"),
      to: `/companies/${companySlug}/projects/${projectId}/status_report_dashboard`,
    },
    {
      label: t("breadcrumbs_links.lead_time_dashboard"),
      to: `/companies/${companySlug}/projects/${projectId}/lead_time_dashboard`,
    },
    {
      label: t("breadcrumbs_links.financial_report"),
      to: `/companies/${companySlug}/projects/${projectId}/financial_report`,
    },
  ]

  const currentOperationalRisk = projectInfo?.currentRiskToDeadline || 0
  const currentRiskToDeadlinePercentage = (
    currentOperationalRisk * 100
  ).toFixed(2)
  const remainingDays = projectInfo?.remainingDays
  const currentTeamRisk = projectInfo?.currentTeamBasedRisk || 0
  const currentTeamRiskPercentage = (currentTeamRisk * 100).toFixed(2)
  const cardTypeTeamRisk = assignCardTypeByRisk(currentTeamRisk)
  const cardTypeOperationalRisk = assignCardTypeByRisk(currentOperationalRisk)

  const actions = [
    {
      name: t("settings_actions.update_cache"),
      onClick: () =>
        generateProjectCache({
          variables: { projectId },
        }),
    },
    {
      name: t("settings_actions.edit_demands"),
      href: `/companies/${companySlug}/projects/${projectId}/edit`,
    },
    {
      name: t("settings_actions.jira_settings"),
      href: `/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs`,
    },
    {
      name: t("settings_actions.projects_stages"),
      href: `/companies/${companySlug}/projects/${projectId}/stage_project_configs`,
    },
    {
      name: t("settings_actions.risk_settings"),
      href: `/companies/${companySlug}/projects/${projectId}/project_risk_configs`,
    },
  ]
  const taskTabs = [
    {
      label: t("tabs.demands"),
      to: `/companies/${companySlug}/projects/${projectId}`,
    },
    {
      label: t("tabs.tasks"),
      to: `/companies/${companySlug}/projects/${projectId}/tasks_tab`,
    },
  ]

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      actions={<ActionMenu items={actions} />}
      loading={loading || queryLoading}
    >
      <>
        {projectIsRunning && (
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
        {dashboard && (
          <Box
            sx={{
              mt: 2,
              mb: 6,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <Tabs tabs={taskTabs} currentPath={pathname} />
          </Box>
        )}
        {children}
      </>
    </BasicPage>
  )
}
