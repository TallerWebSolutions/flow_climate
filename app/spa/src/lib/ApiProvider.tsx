import {
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  createHttpLink,
} from "@apollo/client"
import { ReactElement } from "react"
import { useCookies } from "react-cookie"

const httpLink = createHttpLink({
  uri: "http://localhost:3000/graphql",
  useGETForQueries: false,
  credentials: "same-origin",
})

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
})

type ApiProviderProps = {
  children: ReactElement
}

const ApiProvider = ({ children }: ApiProviderProps) => {
  const [cookies, setCookie, removeCookie] = useCookies(["_fc_session"])

  console.log({ cookies, setCookie, removeCookie })
  return <ApolloProvider client={client}>{children}</ApolloProvider>
}

export default ApiProvider
