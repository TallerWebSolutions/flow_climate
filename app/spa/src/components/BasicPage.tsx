import { ReactElement, useContext } from "react"
import { Container, Typography, Box } from "@mui/material"
import Header from "./Header"
import MessagesBox from "./MessagesBox"
import Breadcrumbs, { BreadcrumbsLink } from "./Breadcrumbs"
import { Company } from "../modules/company/company.types"
import { MessagesContext } from "../contexts/MessageContext"

export type BasicPageProps = {
  title?: string
  breadcrumbsLinks: BreadcrumbsLink[]
  children?: ReactElement | ReactElement[]
  company?: Company
  actions?: ReactElement | ReactElement[]
}

const BasicPage = ({
  children,
  title,
  breadcrumbsLinks,
  company,
  actions,
}: BasicPageProps) => {
  const { messages } = useContext(MessagesContext)

  return (
    <>
      <Header company={company} />
      <Container maxWidth="xl">
        <Breadcrumbs links={breadcrumbsLinks} />
        <Box
          sx={{
            marginBottom: 3,
            display: "flex",
            alignItems: "center",
          }}
        >
          <Typography component="h1" variant="h4" mr={2}>
            {title}
          </Typography>
          {actions}
        </Box>
        {children}
        <MessagesBox messages={messages} />
      </Container>
    </>
  )
}

export default BasicPage
