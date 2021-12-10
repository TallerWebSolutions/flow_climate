import { CookiesProvider, useCookies } from "react-cookie"
import "./App.css"
import ApiProvider from "./lib/ApiProvider"
import Replenishment from "./pages/Replenishment"

const App = () => <Replenishment />

const AppWithProviders = () => {
  const truco = useCookies(["_fc_session"])
  console.log({ truco })
  return (
    <CookiesProvider>
      <ApiProvider>
        <App />
      </ApiProvider>
    </CookiesProvider>
  )
}

export default AppWithProviders
