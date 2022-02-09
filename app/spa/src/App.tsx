import { Fragment } from "react"
import { BrowserRouter, Route, Routes } from "react-router-dom"
import { Helmet } from "react-helmet"

import ApiProvider from "./lib/ApiProvider"
import ThemeProvider from "./lib/ThemeProvider"
import Replenishing from "./pages/Replenishing"
import StatusReport from "./pages/StatusReport"

import "./lib/i18n"

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
          path="/companies/taller/projects/:projectId/status_report"
          element={<StatusReport />}
        />
      </Routes>
    </BrowserRouter>
  </Fragment>
)

const AppWithProviders = () => (
  <ApiProvider>
    <ThemeProvider>
      <App />
    </ThemeProvider>
  </ApiProvider>
)

export default AppWithProviders
