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

import "./lib/i18n"
import Teams from "./pages/Teams"

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
          path="/companies/taller/projects/:projectId/status_report_dashboard"
          element={<StatusReport />}
        />
        <Route
          path="/companies/taller/projects/:projectId/risk_drill_down"
          element={<RiskDrill />}
        />
        <Route
          path="/companies/taller/projects/:projectId/lead_time_dashboard"
          element={<LeadTimeDashboard />}
        />
        <Route
          path="/companies/taller/projects/:projectId/statistics_tab"
          element={<Statistics />}
        />
        <Route path="/companies/taller/teams" element={<Teams />} />
      </Routes>
    </BrowserRouter>
  </Fragment>
)

const AppWithProviders = () => (
  <ApiProvider>
    <ThemeProvider>
      <ConfirmProvider>
        <App />
      </ConfirmProvider>
    </ThemeProvider>
  </ApiProvider>
)

export default AppWithProviders
