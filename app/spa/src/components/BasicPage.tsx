import { ReactElement, ReactNode, useContext } from "react"
import {
  Container,
  Typography,
  Box,
  Link,
  Backdrop,
  CircularProgress,
} from "@mui/material"
import Header from "./Header"
import MessagesBox from "./MessagesBox"
import Breadcrumbs, { BreadcrumbsLink } from "./Breadcrumbs"
import { MessagesContext } from "../contexts/MessageContext"

export type BasicPageProps = {
  breadcrumbsLinks: BreadcrumbsLink[]
  title?: string
  children?: ReactNode | ReactNode[]
  actions?: ReactElement | ReactElement[]
  loading?: boolean
}

const BasicPage = ({
  breadcrumbsLinks,
  title,
  children,
  actions,
  loading,
}: BasicPageProps) => {
  const { messages } = useContext(MessagesContext)

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <>
      <Header />
      <Container maxWidth="xl">
        <Breadcrumbs links={breadcrumbsLinks} />
        <Box
          sx={{
            marginBottom: 3,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <Typography component="h1" variant="h4" mr={2}>
            {title}
          </Typography>
          {actions && actions}
        </Box>
        {children}
        <MessagesBox messages={messages} />
      </Container>
      <Box sx={{ backgroundColor: "primary.main", py: 7, mt: 11 }}>
        <Container>
          <Link href="/" sx={{ display: "block" }}>
            <img
              src="https://res.cloudinary.com/taller-digital/image/upload/v1599220860/2_taller_branco_horizontal.png"
              alt="Taller Logo"
              height={64}
            />
          </Link>
        </Container>
      </Box>
    </>
  )
}

export default BasicPage
