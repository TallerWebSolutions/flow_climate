import { Fragment } from "react"
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
import Tasks from "./pages/Tasks"

import "./lib/i18n"
import { MessagesContext } from "./contexts/MessageContext"
import { useMessages } from "./hooks/useMessages"

const App = () => (
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
        <Route path="/companies/:companyNickName/tasks" element={<Tasks />} />
      </Routes>
    </BrowserRouter>
  </Fragment>
)

const AppWithProviders = () => {
  const [messages, pushMessage] = useMessages()

  return (
    <ApiProvider>
      <ThemeProvider>
        <ConfirmProvider>
          <MessagesContext.Provider value={{ messages, pushMessage }}>
            <App />
          </MessagesContext.Provider>
        </ConfirmProvider>
      </ThemeProvider>
    </ApiProvider>
  )
}

export default AppWithProviders
