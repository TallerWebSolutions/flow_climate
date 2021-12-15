import { BrowserRouter, Route, Routes } from "react-router-dom"
import ApiProvider from "./lib/ApiProvider"
import Replenishment from "./pages/Replenishment"

const App = () => (
  <BrowserRouter>
    <Routes>
      <Route
        path="/companies/taller/teams/:teamId/replenishing_consolidations"
        element={<Replenishment />}
      />
    </Routes>
  </BrowserRouter>
)

const AppWithProviders = () => (
  <ApiProvider>
    <App />
  </ApiProvider>
)

export default AppWithProviders
