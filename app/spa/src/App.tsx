import { Fragment } from "react"
import { BrowserRouter, Route, Routes } from "react-router-dom"
import { Helmet } from "react-helmet"

import ApiProvider from "./lib/ApiProvider"
import ThemeProvider from "./lib/ThemeProvider"
import Replenishment from "./pages/Replenishment"

const App = () => (
  <Fragment>
    <Helmet>
      <title>Flow Climate - Mastering the flow management</title>
    </Helmet>
    <BrowserRouter>
      <Routes>
        <Route
          path="/companies/:companyNickName/teams/:teamId/replenishing_consolidations"
          element={<Replenishment />}
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
