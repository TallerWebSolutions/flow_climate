import { Box, Button, FormControl, FormGroup, Input, InputLabel, Link } from "@mui/material"
import { gql, useMutation, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import { useContext } from "react"
import { useForm } from "react-hook-form"
import { useParams } from "react-router-dom"
import { MessagesContext } from "../../contexts/MessageContext"

type JiraProjectConfigDTO = {
  project: string
  jiraProjectConfig: string
  fixVersionName: string
}
 

export const JIRA_PROJECT_CONFIG_EDIT_QUERY = gql`
  query JiraProjectConfigEdit($jiraProjectConfigEditId: String!) {
    jiraProjectConfigEdit(id: $jiraProjectConfigEditId) {
      id
      name
    }
  }
`

type UpdateJiraProjectConfigDTO = {
  updateJiraProjectConfigEdit: {
    statusMessage: string    
  }
}

const UPDATE_JIRA_PROJECT_CONFIG_EDIT_MUTATION = gql`
  mutation JiraProjectConfigEdit($jiraProductKey: String!, $fixVersionName: String!, $id: String!) {
    updateJiraProjectConfig(jiraProjectConfigId: $jiraProjectConfigId, name: $name) {
      id
      statusMessage
      }
    }
`

const JiraProjectConfigEdit = () => {
  const { t } = useTranslation(["teamMembers" ])
  const { id } = useParams()
  const { pushMessage } = useContext(MessagesContext)
 // const navigate = useNavigate()
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const { data, loading } = useQuery<JiraProjectConfigDTO>(JIRA_PROJECT_CONFIG_EDIT_QUERY, {
    variables: {
      id: Number(id),
    },
  })
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [UpdateJiraProjectConfigEdit] = useMutation<UpdateJiraProjectConfigDTO>
    (UPDATE_JIRA_PROJECT_CONFIG_EDIT_MUTATION, {
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

    //  navigate(`/companies/${companyId}/teams/${newJiraProjectConfigId}`)
    },
  })

  const { register, handleSubmit } = useForm()

  const handleJiraProjectConfigEdit = (data: any) => {
    const { jiraProductKey, fixVersionName } = data

    UpdateJiraProjectConfigEdit({
      variables: {
        fixVersionName, jiraProductKey, id

      },
    })
    // eslint-disable-next-line no-console
    console.log(jiraProductKey, fixVersionName)
  }


  return (
    <BasicPage title='Editar Configuração do Jira' breadcrumbsLinks={[]}loading={loading}> 
      
        <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4, }}>
          <form onSubmit={handleSubmit(handleJiraProjectConfigEdit)}>
            <FormGroup>
              <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="component-simple">Config do Produto</InputLabel>
              <Input {...register("jiraProductKey")} />
                         
              </FormControl>
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


