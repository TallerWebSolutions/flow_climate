import { BrowserRouter, Route, Routes } from "react-router-dom"
import ApiProvider from "./lib/ApiProvider"
import ThemeProvider from "./lib/ThemeProvider"
import Replenishment from "./pages/Replenishment"

const App = () => (
  <BrowserRouter>
    <Routes>
      <Route
        path="/companies/:companyNickName/teams/:teamId/replenishing_consolidations"
        element={<Replenishment />}
      />
    </Routes>
  </BrowserRouter>
)

const AppWithProviders = () => (
  <ApiProvider>
    <ThemeProvider>
      <App />
    </ThemeProvider>
  </ApiProvider>
)

export default AppWithProviders
