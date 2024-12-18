import { gql, useQuery } from "@apollo/client"
import { ConfirmProvider } from "material-ui-confirm"
import { Fragment, useEffect } from "react"
import { Helmet } from "react-helmet"
import { I18nextProvider } from "react-i18next"

import { MessagesContext } from "./contexts/MessageContext"
import { MeContext } from "./contexts/MeContext"
import { useMessages } from "./hooks/useMessages"
import ApiProvider from "./lib/ApiProvider"
import i18n, { loadLanguage } from "./lib/i18n"
import ThemeProvider from "./lib/ThemeProvider"
import { User } from "./modules/user/user.types"
import Routes from "./Routes"

export const ME_QUERY = gql`
  query Me {
    me {
      id
      language
      userIsManager
      projectsActive {
        id
        name

        demandsBurnup {
          scope
          xAxis
          idealBurn
          currentBurn
        }
      }
      currentCompany {
        id
        name
        slug
        workItemTypes {
          id
          name
        }
        projects {
          id
          name
        }
        teams {
          id
          name
        }
      }
      fullName
      avatar {
        imageSource
      }
      admin
      companies {
        id
        name
        slug
      }
    }
  }
`

type MeDTO = {
  me: User
}

const App = () => {
  const { data, loading } = useQuery<MeDTO>(ME_QUERY, {
    notifyOnNetworkStatusChange: true,
  })

  useEffect(() => {
    if (!loading) loadLanguage(data?.me.language)
  }, [data, loading])

  return (
    <Fragment>
      <Helmet>
        <title>Flow Climate - Mastering the flow management</title>
      </Helmet>
      <MeContext.Provider value={{ me: data?.me, loading }}>
        <Routes />
      </MeContext.Provider>
    </Fragment>
  )
}

const AppWithProviders = () => {
  const [messages, pushMessage] = useMessages()
  const userProfile = window?.location?.pathname?.includes("devise_customers")
    ? "customer"
    : "user"

  return (
    <ApiProvider userProfile={userProfile}>
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
