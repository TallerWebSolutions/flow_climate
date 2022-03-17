import { ReactElement, useContext } from "react"
import { Container, Typography } from "@mui/material"
import Header from "./Header"
import MessagesBox from "./MessagesBox"
import Breadcrumbs, { BreadcrumbsLink } from "./Breadcrumbs"
import { Company } from "../modules/company/company.types"
import { MessagesContext } from "../contexts/MessageContext"

export type BasicPageProps = {
  title: string
  breadcrumbsLinks: BreadcrumbsLink[]
  children?: ReactElement | ReactElement[]
  company?: Company
}

const BasicPage = ({
  children,
  title,
  breadcrumbsLinks,
  company,
}: BasicPageProps) => {
  const { messages } = useContext(MessagesContext)

  return (
    <>
      <Header company={company} />
      <Container maxWidth="xl">
        <Breadcrumbs links={breadcrumbsLinks} />
        <Typography component="h1" variant="h4" mb={3}>
          {title}
        </Typography>
        {children}
        <MessagesBox messages={messages} />
      </Container>
    </>
  )
}

export default BasicPage
