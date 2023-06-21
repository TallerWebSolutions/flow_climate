import { gql, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { JiraProjectConfig } from "../../modules/project/jiraProjectConfig.types"
import { useParams } from "react-router-dom"
import BasicPage from "../../components/BasicPage"
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography } from "@mui/material"
import { Link as RouterLink } from "react-router-dom"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"
import { useContext } from "react"
import { MeContext } from "../../contexts/MeContext"


type JiraProjectConfigListDTO = {
  jiraProjectConfigList?: JiraProjectConfig
}

export const JIRA_PROJECT_CONFIG_TABLE_QUERY = gql`
  query JiraProjectConfigList($projectId: ID!){
    jiraProjectConfigList (id: $projectId) {
      id
      fixVersionName
      jiraProductConfig {
        id
        jiraProductKey
      }
    }
  }
`
const JiraProjectConfigList = () => {
  const { t } = useTranslation(["jiraProjectConfigList"])
  const params = useParams()

  
  const companySlug = params.company_id
  const projectId = params.project_id

  const { data, loading } =
    useQuery<JiraProjectConfigListDTO>(JIRA_PROJECT_CONFIG_TABLE_QUERY,
      { 
        variables: {
          projectId: projectId, 
        },
      }
    )
  // eslint-disable-next-line no-console
  console.log({ data, loading, projectId })
  const jiraId =data?.jiraProjectConfigList?.id || 0
  const fixVersionName = data?.jiraProjectConfigList?.fixVersionName || ""
  const productKey = data?.jiraProjectConfigList?.jiraProductConfig?.jiraProductKey || ""
   

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
      url: `/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs`
    },
    ]

  return (
    <BasicPage
      title={t("jiraProjectConfig")}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
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
              <TableRow>
                <TableCell>{`${productKey}`}</TableCell>
                <TableCell>{`${fixVersionName}`}</TableCell>
                  <RouterLink to=
                   {`/companies/${companySlug}/jira/projects/${projectId}/jira_project_configs/${jiraId}/edit`}>
                    <EditOutlinedIcon color="primary" />
                </RouterLink>
              </TableRow>
            </TableBody>
          </Table>
        </TableContainer>
      </Box>
    </BasicPage>
  );
};
 
export default JiraProjectConfigList