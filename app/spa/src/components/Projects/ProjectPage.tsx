import { gql, useMutation } from "@apollo/client"
import { Box } from "@mui/material"
import { ReactNode, useContext } from "react"
import { useTranslation } from "react-i18next"
import { useLocation, useParams } from "react-router-dom"
import { MessagesContext } from "../../contexts/MessageContext"
import useProjectInfo from "../../hooks/useProjectInfo"
import ActionMenu from "../menu/ActionMenu"
import BasicPage from "../BasicPage"
import { Tabs } from "../Tabs"
import ProjectRiskCards from "../../modules/project/components/ProjectRiskCards"

export const ProjectPage = ({
  pageName,
  children,
  loading,
}: ProjectPageProps) => {
  const { pathname } = useLocation()
  const { t } = useTranslation(["generalProjectPage"])
  const { pushMessage } = useContext(MessagesContext)
  const [generateProjectCache] = useMutation<ProjectCacheDTO>(
    GENERATE_PROJECT_CACHE_MUTATION,
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
  const companyID = company?.id || ""
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
      href: `/companies/${companyID}/jira/projects/${projectId}/jira_project_configs/`,
    },
    {
      name: t("settings_actions.projects_stages"),
      href: `/companies/${companySlug}/projects/${projectId}/stage_project_configs`,
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
        {projectIsRunning && projectInfo && (
          <ProjectRiskCards
            remainingDays={projectInfo.remainingDays || 0}
            currentOperationalRisk={projectInfo.currentRiskToDeadline || 0}
            currentTeamRisk={projectInfo.currentTeamBasedRisk || 0}
          />
        )}
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <Tabs tabs={projectTabs} currentPath={pathname} />
        </Box>
        {children}
      </>
    </BasicPage>
  )
}

export const PROJECT_STANDARD_FRAGMENT = gql`
  fragment ProjectStandardFragment on Project {
    id
    name
    endDate
    remainingDays
    currentRiskToDeadline
    currentTeamBasedRisk
    company {
      id
      name
      slug
    }
  }
`

type ProjectPageProps = {
  pageName: string
  children: ReactNode
  loading?: boolean
}

const GENERATE_PROJECT_CACHE_MUTATION = gql`
  mutation GenerateProjectCache($projectId: ID!) {
    generateProjectCache(projectId: $projectId) {
      statusMessage
    }
  }
`

type ProjectCacheDTO = {
  generateProjectCache?: {
    statusMessage: string
  }
}
