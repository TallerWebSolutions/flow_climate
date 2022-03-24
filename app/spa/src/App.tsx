import { Fragment, useEffect } from "react"
import { BrowserRouter, Route, Routes } from "react-router-dom"
import { Helmet } from "react-helmet"
import { ConfirmProvider } from "material-ui-confirm"

import ApiProvider from "./lib/ApiProvider"
import ThemeProvider from "./lib/ThemeProvider"
import Replenishing from "./pages/Replenishing"
import StatusReport from "./pages/StatusReport"
import RiskDrill from "./pages/RiskDrill"
import LeadTimeDashboard from "./pages/LeadTimeDashboard"
import Statistics from "./pages/Statistics"
import Teams from "./pages/Teams/Teams"
import CreateTeam from "./pages/Teams/CreateTeam"
import EditTeam from "./pages/Teams/EditTeam"
import TasksList from "./pages/Tasks/List"
import Charts from "./pages/Tasks/Charts"

import i18n, { loadLanguage } from "./lib/i18n"
import { MessagesContext } from "./contexts/MessageContext"
import { useMessages } from "./hooks/useMessages"
import { I18nextProvider } from "react-i18next"
import { gql, useQuery } from "@apollo/client"

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
            path="/companies/:companyNickName/teams/:teamId/replenishing_consolidations"
            element={<Replenishing />}
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
            path="/companies/:companyNickName/tasks"
            element={<TasksList />}
          />
          <Route
            path="/companies/:companyNickName/tasks/charts"
            element={<Charts />}
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
