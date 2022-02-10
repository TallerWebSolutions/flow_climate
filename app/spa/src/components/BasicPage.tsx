import { Fragment, ReactElement } from "react"
import Header from "./Header"

type BasicPageProps = {
  children: ReactElement | ReactElement[]
}

const BasicPage = ({ children }: BasicPageProps) => (
  <Fragment>
    <Header />
    {children}
  </Fragment>
)

export default BasicPage
