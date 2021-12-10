import {
  ApolloClient,
  InMemoryCache,
  ApolloProvider,
  createHttpLink,
} from "@apollo/client"
import { ReactElement } from "react"

// @ts-ignore: Object is possibly 'null'.
const csrfToken: any = document.querySelector('meta[name=csrf-token]').getAttribute('content');

const httpLink = createHttpLink({
  uri: "http://localhost:3000/graphql",
  useGETForQueries: false,
  credentials: "same-origin",
  headers: {
    'X-CSRF-Token': csrfToken
  }
})

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache(),
})

type ApiProviderProps = {
  children: ReactElement
}

const ApiProvider = ({ children }: ApiProviderProps) => {
  return <ApolloProvider client={client}>{children}</ApolloProvider>
}

export default ApiProvider
