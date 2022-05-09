import { gql, useQuery } from "@apollo/client"
import { ConfirmProvider } from "material-ui-confirm"
import { Fragment, useEffect } from "react"
import { Helmet } from "react-helmet"
import { I18nextProvider } from "react-i18next"
import { BrowserRouter, Route, Routes } from "react-router-dom"
import { MessagesContext } from "./contexts/MessageContext"
import { useMessages } from "./hooks/useMessages"
import ApiProvider from "./lib/ApiProvider"
import i18n, { loadLanguage } from "./lib/i18n"
import ThemeProvider from "./lib/ThemeProvider"
import LeadTimeDashboard from "./pages/Projects/LeadTimeDashboard"
import ProjectCharts from "./pages/Projects/ProjectCharts"
import ProjectFinancialReport from "./pages/Projects/ProjectFinancialReport"
import Replenishing from "./pages/Teams/Replenishing"
import RiskDrill from "./pages/Projects/RiskDrill"
import Statistics from "./pages/Projects/Statistics"
import StatusReport from "./pages/Projects/StatusReport"
import TasksPage from "./pages/Tasks/Tasks"
import CreateTeam from "./pages/Teams/CreateTeam"
import EditTeam from "./pages/Teams/EditTeam"
import Teams from "./pages/Teams/Teams"

const LANGUAGE_LOGGED_USER_QUERY = gql`
  query LanguageOfLoggedUser {
    me {
      language
    }
  }
`

type UserLoggedLanguageDTO = {
  me: {
    language: string
  }
}

const App = () => {
  const { data, loading } = useQuery<UserLoggedLanguageDTO>(
    LANGUAGE_LOGGED_USER_QUERY
  )

  useEffect(() => {
    if (!loading) loadLanguage(data?.me.language)
  }, [data, loading])

  return (
    <Fragment>
      <Helmet>
        <title>Flow Climate - Mastering the flow management</title>
      </Helmet>
      <BrowserRouter>
        <Routes>
          <Route
            path="/companies/:companyNickName/projects/:projectId"
            element={<ProjectCharts />}
          />
          <Route
            path="/companies/:companyNickName/projects/:projectId/status_report_dashboard"
            element={<StatusReport />}
          />
          <Route
            path="/companies/:companyNickName/projects/:projectId/risk_drill_down"
            element={<RiskDrill />}
          />
          <Route
            path="/companies/:companyNickName/projects/:projectId/lead_time_dashboard"
            element={<LeadTimeDashboard />}
          />
          <Route
            path="/companies/:companyNickName/projects/:projectId/statistics_tab"
            element={<Statistics />}
          />
          <Route
            path="/companies/:companyNickName/projects/:projectId/financial_report"
            element={<ProjectFinancialReport />}
          />
          <Route path="/companies/:companyNickName/teams" element={<Teams />} />
          <Route
            path="/companies/:companyNickName/teams/new"
            element={<CreateTeam />}
          />
          <Route
            path="/companies/:companyNickName/teams/:teamId/edit"
            element={<EditTeam />}
          />
          <Route
            path="/companies/:companyNickName/teams/:teamId/replenishing_consolidations"
            element={<Replenishing />}
          />
          <Route
            path="/companies/:companyNickName/tasks"
            element={<TasksPage />}
          />
          <Route
            path="/companies/:companyNickName/tasks/charts"
            element={<TasksPage initialTab={0} />}
          />
        </Routes>
      </BrowserRouter>
    </Fragment>
  )
}

const AppWithProviders = () => {
  const [messages, pushMessage] = useMessages()

  return (
    <ApiProvider>
      <ThemeProvider>
        <ConfirmProvider>
          <MessagesContext.Provider value={{ messages, pushMessage }}>
            <I18nextProvider i18n={i18n}>
              <App />
            </I18nextProvider>
          </MessagesContext.Provider>
        </ConfirmProvider>
      </ThemeProvider>
    </ApiProvider>
  )
}

export default AppWithProviders
