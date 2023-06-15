import {
  Box,
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Link,
} from "@mui/material"
import { gql, useMutation, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import { useContext } from "react"
import { useForm } from "react-hook-form"
import { useNavigate, useParams } from "react-router-dom"
import { MessagesContext } from "../../contexts/MessageContext"
import { MeContext } from "../../contexts/MeContext"
import { JiraProjectConfig } from "../../modules/project/jiraProjectConfig.types"

type JiraProjectConfigDTO = {
  jiraProjectConfig?: JiraProjectConfig
}

type UpdateJiraProjectConfigDTO = {
  updateJiraProjectConfig: {
    statusMessage?: string
    id?: string
  }
}

const EditJiraProjectConfig = () => {
  const { t } = useTranslation(["jiraProjectConfig"])
  const { pushMessage } = useContext(MessagesContext)
  const params = useParams()

  const configId = params.id
  const companySlug = params.companyId
  const projectId = params.projectId

  const { data, loading } = useQuery<JiraProjectConfigDTO>(
    JIRA_PROJECT_CONFIG_QUERY,
    {
      variables: {
        id: configId,
      },
    }
  )

  const fixVersionName = data?.jiraProjectConfig?.fixVersionName || ""

  const [updateJiraProjectConfig] = useMutation<UpdateJiraProjectConfigDTO>(
    UPDATE_JIRA_PROJECT_CONFIG_MUTATION,
    {
      update: (_, { data }) => {
        const mutationResult =
          data?.updateJiraProjectConfig?.statusMessage === "SUCCESS"

        pushMessage({
          text: mutationResult
            ? t("edit.statusMessage.success")
            : t("edit.statusMessage.fail"),
          severity: mutationResult ? "success" : "error",
        })
      },
    }
  )

  const { register, handleSubmit } = useForm<JiraProjectConfig>()

  const handleJiraProjectConfigEdit = (data: JiraProjectConfig) => {
    const { fixVersionName } = data

    updateJiraProjectConfig({
      variables: {
        id: configId,
        fixVersionName: fixVersionName,
      },
    })
  }

  const { me } = useContext(MeContext)
  const company = me?.currentCompany

  const breadcrumbsLinks = [
    {
      name: company?.name || "",
      url: `/companies/${companySlug}`,
    },
    {
      name: t("breadcrumbs.jiraProjectConfig.title"),
      url: `/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs`,
    },
  ]

  return (
    <BasicPage
      title="Editar Configuração do Jira"
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
      <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4 }}>
        <form onSubmit={handleSubmit(handleJiraProjectConfigEdit)}>
          <FormGroup>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="component-simple">
                Fix Version ou Label no Jira
              </InputLabel>
              <Input
                defaultValue={fixVersionName}
                {...register("fixVersionName")}
              />
            </FormControl>

            <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
              <Button type="submit" variant="contained" sx={{ marginRight: 2 }}>
                {t("edit.form.save")}
              </Button>
              <Button variant="outlined" component={Link}>
                {t("edit.form.cancel")}
              </Button>
            </Box>
          </FormGroup>
        </form>
      </Box>
    </BasicPage>
  )
}

export const JIRA_PROJECT_CONFIG_QUERY = gql`
  query JiraProjectConfig($id: ID!) {
    jiraProjectConfig(id: $id) {
      id
      fixVersionName
    }
  }
`

const UPDATE_JIRA_PROJECT_CONFIG_MUTATION = gql`
  mutation JiraProjectConfig($id: ID!, $fixVersionName: String!) {
    updateJiraProjectConfig(id: $id, fixVersionName: $fixVersionName) {
      id
      statusMessage
    }
  }
`

export default EditJiraProjectConfig
