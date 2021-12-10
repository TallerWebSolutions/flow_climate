import ApiProvider from "./lib/ApiProvider"
import Replenishment from "./pages/Replenishment"

const App = () => <Replenishment />

const AppWithProviders = () => (
  <ApiProvider>
    <App />
  </ApiProvider>
)

export default AppWithProviders
