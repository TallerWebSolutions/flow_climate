import {
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  createHttpLink,
} from "@apollo/client"
import { ReactElement } from "react"

const csrfToken =
  document.querySelector("meta[name='csrf-token']")?.getAttribute("content") ||
  ""

const httpLink = (userProfile: string) =>
  createHttpLink({
    uri: "/graphql",
    useGETForQueries: false,
    credentials: "same-origin",
    headers: {
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Dest": "empty",
      "X-CSRF-Token": csrfToken,
      userProfile,
    },
  })

const client = (userProfile: string) =>
  new ApolloClient({
    link: httpLink(userProfile),
    cache: new InMemoryCache(),
  })

type ApiProviderProps = {
  children: ReactElement
  userProfile: string
}

const ApiProvider = ({ children, userProfile }: ApiProviderProps) => {
  return (
    <ApolloProvider client={client(userProfile)}>{children}</ApolloProvider>
  )
}

export default ApiProvider
