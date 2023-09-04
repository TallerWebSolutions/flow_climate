import { gql, useMutation, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { JiraProjectConfig } from "../../modules/project/jiraProjectConfig.types"
import { useParams } from "react-router-dom"
import BasicPage from "../../components/BasicPage"
import {
  Box,
  Button,
  Link,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
} from "@mui/material"
import { Link as RouterLink } from "react-router-dom"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"
import { useContext } from "react"
import { MeContext } from "../../contexts/MeContext"
import { MessagesContext } from "../../contexts/MessageContext"

type JiraProjectConfigListDTO = {
  jiraProjectConfigList?: JiraProjectConfig[]
}

type SynchroniseJiraProjectConfigDTO = {
  synchroniseJiraProjectConfig: {
    statusMessage?: string
    id?: string
  }
}

const JiraProjectConfigList = () => {
  const { t } = useTranslation(["jiraProjectConfigList"])
  const { pushMessage } = useContext(MessagesContext)
  const params = useParams()

  const configId = params.id
  const companySlug = params.companyId
  const projectId = params.projectId

  const { data, loading } = useQuery<JiraProjectConfigListDTO>(
    JIRA_PROJECT_CONFIG_LIST_QUERY,
    {
      variables: {
        projectId: projectId,
      },
    }
  )


  const [synchroniseJiraProjectConfig] = useMutation<SynchroniseJiraProjectConfigDTO>(
    SYNCHRONISE_JIRA_PROJECT_CONFIG_MUTATION,
    {
      update: (_, { data }) => {
        const mutationResult =
          data?.synchroniseJiraProjectConfig?.statusMessage === "SUCCESS"

        pushMessage({
          text: mutationResult
            ? t("edit.statusMessage.success")
            : t("edit.statusMessage.fail"),
          severity: mutationResult ? "success" : "error",
        })
      },
    }
  )


  const handleJiraProjectConfigSynchronise = (event: React.MouseEvent<HTMLButtonElement>) => {

    synchroniseJiraProjectConfig({
      variables: {
        id: configId
      },
    })
  }

  const jiraConfigList = data?.jiraProjectConfigList

  const { me } = useContext(MeContext)
  const company = me?.currentCompany

  const breadcrumbsLinks = [
    {
      name: company?.name || "",
      url: `/companies/${companySlug}`,
    },
    {
      name: t("breadcrumbs.jiraProjectConfigList.projects"),
      url: `/companies/${companySlug}/projects`,
    },
    {
      name: t("breadcrumbs.jiraProjectConfigList.title"),
      url: `/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs`,
    },
  ]

  return (
    <BasicPage
      title={t("jiraProjectConfig")}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
      <Box sx={{ display: "flex", justifyContent: "flex-end" }}>
        <Link
          href={`/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs/new`}
        >
          <Button variant="contained">{t("list.new")}</Button>
        </Link>
      </Box>
      <Box sx={{ marginY: 4 }}>
        <TableContainer component={Paper} sx={{ backgroundColor: "white" }}>
          <Typography
            color="primary"
            variant="h6"
            component="h6"
            sx={{
              padding: 2,
              display: "flex",
              justifyContent: "space-between",
            }}
          >
            {t("list.title")}
          </Typography>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t("fields.productConfig")}</TableCell>
                <TableCell>{t("fields.fixVersionOrLabelOnJira")}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {jiraConfigList?.map((config) => (
                <TableRow>
                  <TableCell>
                    {config?.jiraProductConfig?.jiraProductKey}
                  </TableCell>
                  <TableCell>{config?.fixVersionName}</TableCell>
                  <RouterLink
                    to={`/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs/${config?.id}/edit`}
                  >
                    <EditOutlinedIcon color="primary" />
                  </RouterLink>
                  <EditOutlinedIcon color="primary" />

                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>
    </BasicPage>
  )
}

export const JIRA_PROJECT_CONFIG_LIST_QUERY = gql`
  query JiraProjectConfigList($projectId: ID!) {
    jiraProjectConfigList(id: $projectId) {
      id
      fixVersionName
      jiraProductConfig {
        id
        jiraProductKey
      }
    }
  }
`

export const SYNCHRONISE_JIRA_PROJECT_CONFIG_MUTATION = gql`
  mutation JiraProjectConfig($id: ID!) {
    synchroniseJiraProjectConfig(id: $id) {
      id
      statusMessage
    }
  }
`

export default JiraProjectConfigList
