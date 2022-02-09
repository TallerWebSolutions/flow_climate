import React from "react"
import { Avatar, Box, Container, Link, Menu, MenuItem } from "@mui/material"
import { useState } from "react"
import { gql, useMutation } from "@apollo/client"

import { t } from "../lib/i18n"
import { useMessages } from "../pages/Replenishing"

import { Message } from "./MessagesBox"

const buildLinks = (companyName: string) => [
  { name: "Taller", href: `/companies/${companyName}` },
  { name: "Clientes", href: `/companies/${companyName}/customers` },
  { name: "Produtos", href: `/companies/${companyName}/products` },
  { name: "Iniciativas", href: `/companies/${companyName}/initiatives` },
  { name: "Projetos", href: `/companies/${companyName}/projects` },
  { name: "Demandas", href: `/companies/${companyName}/demands` },
  { name: "Bloqueios", href: `/companies/${companyName}/demand_blocks` },
  { name: "Eventos", href: `/companies/${companyName}/flow_events` },
]

export type User = {
  id: string
  avatarSource: string
  fullName: string
}

type Company = {
  id: string
  name: string
  slug: string
}

type HeaderProps = {
  pushMessage: (message: Message) => void
  company?: Company
  user?: User
}

const SEND_API_TOKEN_MUTATION = gql`
  mutation SendAuthToken($companyId: Int!) {
    sendAuthToken(companyId: $companyId) {
      statusMessage
    }
  }
`

const Header = ({ company, user }: HeaderProps) => {
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const handleClose = () => setAnchorEl(null)
  const [_, pushMessage] = useMessages()

  const [sendAuthTokenMutation] = useMutation(SEND_API_TOKEN_MUTATION, {
    update: () =>
      pushMessage({
        text: "Token enviado com sucesso! Em poucos minutos estará disponível em seu e-mail.",
        severity: "info",
      }),
  })

  return (
    <Box py={1} sx={{ backgroundColor: "primary.main" }}>
      <Container maxWidth="xl">
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Link href="/" sx={{ display: "block" }}>
            <img
              src="https://res.cloudinary.com/taller-digital/image/upload/v1599220860/2_taller_branco_horizontal.png"
              alt="Taller Logo"
              height={64}
            />
          </Link>
          {company &&
            buildLinks(company.slug).map((link, index) => (
              <Link
                sx={{ textDecoration: "none" }}
                px={2}
                key={link.name + index}
                href={link.href}
                color="secondary.contrastText"
              >
                {link.name}
              </Link>
            ))}
          {user && (
            <Avatar
              alt={user.fullName}
              src={user.avatarSource}
              onClick={(e) => setAnchorEl(e.currentTarget)}
              sx={{ cursor: "pointer" }}
            />
          )}
          <Menu
            anchorEl={anchorEl}
            keepMounted
            open={Boolean(anchorEl)}
            onClose={handleClose}
            anchorOrigin={{
              vertical: "bottom",
              horizontal: "right",
            }}
            transformOrigin={{
              vertical: "top",
              horizontal: "right",
            }}
          >
            {user && (
              <MenuItem component="a" href={`/users/${user.id}/edit`}>
                {t("userMenu.myAccount")}
              </MenuItem>
            )}
            <MenuItem component="a" href="/users/activate_email_notifications">
              {t("userMenu.turnOnNotifications")}
            </MenuItem>
            {company && (
              <React.Fragment>
                <MenuItem
                  onClick={() =>
                    sendAuthTokenMutation({
                      variables: { companyId: Number(company.id) },
                    })
                  }
                  component="a"
                >
                  Solicitar API Token
                </MenuItem>
                <MenuItem component="a" href={`/companies/${company.slug}`}>
                  {company.name}
                </MenuItem>
              </React.Fragment>
            )}
            <MenuItem component="a" href="/users/admin_dashboard">
              {t("userMenu.adminDashboard")}
            </MenuItem>
            <MenuItem component="a" href="/users/sign_out">
              {t("userMenu.logout")}
            </MenuItem>
          </Menu>
        </Box>
      </Container>
    </Box>
  )
}

export default Header
