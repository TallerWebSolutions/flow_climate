import { ReactNode, useContext } from "react"
import {
  Backdrop,
  Box,
  CircularProgress,
  Container,
  Stack,
  Typography,
} from "@mui/material"
import Header from "./Header"
import MessagesBox from "./MessagesBox"
import Breadcrumbs, { BreadcrumbsLink } from "./Breadcrumbs"
import { MessagesContext } from "../contexts/MessageContext"
import Footer from "./Footer"

export type BasicPageProps = {
  breadcrumbsLinks?: BreadcrumbsLink[]
  title?: string
  children?: ReactNode
  actions?: ReactNode
  loading?: boolean
}
const BasicPage = ({
  breadcrumbsLinks,
  title,
  children,
  actions,
  loading = false,
}: BasicPageProps) => {
  const { messages } = useContext(MessagesContext)

  return (
    <>
      {loading && (
        <Backdrop open sx={{ zIndex: 10 }}>
          <CircularProgress color="secondary" />
        </Backdrop>
      )}
      <Stack sx={{ height: "100%" }}>
        <Header />
        <Container
          maxWidth="xl"
          sx={{ backgroundColor: "grey.100", paddingBottom: 8, flex: 1 }}
        >
          {breadcrumbsLinks && <Breadcrumbs links={breadcrumbsLinks} />}
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
        <Footer />
      </Stack>
    </>
  )
}

export default BasicPage
