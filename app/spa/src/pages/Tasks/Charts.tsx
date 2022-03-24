import { gql, useQuery } from "@apollo/client"
import { Box, CircularProgress } from "@mui/material"
import { useEffect, useState } from "react"
import { useTranslation } from "react-i18next"
import { useLocation } from "react-router-dom"
import TasksPage, { TaskFilters } from "../../components/TaskPage"
import { Company } from "../../modules/company/company.types"
import User from "../../modules/user/user.types"

const TASKS_CHARTS_QUERY = gql`
  query TasksChartsQuery {
    me {
      currentCompany {
        name
        slug
      }
    }
  }
`

type TasksChartsDTO = {
  me: User
}

const Charts = () => {
  const { t } = useTranslation(["tasks"])
  const { pathname } = useLocation()
  const [company, setCompany] = useState<Company | null>(null)
  const [taskFilters, setTaskFilters] = useState<TaskFilters>({
    page: 0,
    limit: 10,
  })

  const { data, loading } = useQuery<TasksChartsDTO>(TASKS_CHARTS_QUERY, {
    variables: { ...taskFilters },
  })

  useEffect(() => {
    if (!loading) {
      setCompany(data?.me.currentCompany!)
    }
  }, [data, loading])

  const breadcrumbsLinks = [
    { name: String(company?.name) || "", url: String(company?.slug) },
    { name: t("charts") },
  ]

  return (
    <TasksPage
      title={t("tasks")}
      breadcrumbsLinks={breadcrumbsLinks}
      pathname={pathname}
      onFiltersChange={(filters) => {
        setTaskFilters((prevState) => ({ ...prevState, ...filters }))
      }}
    >
      {loading ? (
        <Box
          sx={{
            width: "100%",
            height: 200,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <CircularProgress color="secondary" />
        </Box>
      ) : (
        <p>Charts</p>
      )}
    </TasksPage>
  )
}

export default Charts
