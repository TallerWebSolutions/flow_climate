import { Box, Button, FormControl, FormGroup, Input, InputLabel, Link } from "@mui/material"
import { gql, useMutation, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import { useContext } from "react"
import { useForm } from "react-hook-form"
import { useNavigate, useParams } from "react-router-dom"
import { MessagesContext } from "../../contexts/MessageContext" 

type JiraProjectConfigDTO = {
  jiraProjectConfigId: string
  fixVersionName: string
  
}
 
export const JIRA_PROJECT_CONFIG_EDIT_QUERY = gql`
  query JiraProjectConfig($jiraProjectConfigId: id!) {
    jiraProjectConfig( fixVersionName: $fixVersionName ) {
      id
      fixVersionName
    }
  }
`
type UpdateJiraProjectConfigDTO = {
  updateJiraProjectConfigEdit: {
    statusMessage: string
    id: Number
  }
}

const UPDATE_JIRA_PROJECT_CONFIG_MUTATION = gql`
  mutation JiraProjectConfig( $id: ID!, $fixVersionName: String! ) {
    updateJiraProjectConfig(id: $id, fixVersionName: $fixVersionName) {
      id
  }
}
`
const JiraProjectConfigEdit = () => {
  const { t } = useTranslation(["teamMembers"])
  const { id } = useParams()
  const { pushMessage } = useContext(MessagesContext)
  const navigate = useNavigate()
  const { loading } = useQuery<JiraProjectConfigDTO>(JIRA_PROJECT_CONFIG_EDIT_QUERY, {
    variables: {
      id: Number(id),
    },
  })

  const [UpdateJiraProjectConfig] = useMutation<UpdateJiraProjectConfigDTO>
    (UPDATE_JIRA_PROJECT_CONFIG_MUTATION, {
      update: (_, { data }) => {
      const mutationResult = data?.updateJiraProjectConfigEdit.statusMessage === "SUCCESS"
      // eslint-disable-next-line no-console
      console.log(mutationResult)
      pushMessage({
        text: mutationResult
          ? t("edit_team.edit_team_message_success")
          : t("edit_team.edit_team_message_fail"),
        severity: mutationResult ? "success" : "error",
      })

    navigate(`/`)
    },
  })

  const { register, handleSubmit } = useForm()

  const handleJiraProjectConfigEdit = (data: any) => {
    const { id, fixVersionName } = data

    UpdateJiraProjectConfig({
      variables: {
        id: String(id),
        fixVersionName: String(fixVersionName)
      },
    })
  }

  return (
    <BasicPage title='Editar Configuração do Jira' breadcrumbsLinks={[]}loading={loading}> 
      
        <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4, }}>
          <form onSubmit={handleSubmit(handleJiraProjectConfigEdit)}>
            <FormGroup>

              <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="component-simple">Fix Version ou Label no Jira</InputLabel>
              <Input {...register("fixVersionName")} />
      
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

export default JiraProjectConfigEdit


