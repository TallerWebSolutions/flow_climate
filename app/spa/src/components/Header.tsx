import React, { useContext } from "react"
import { Avatar, Box, Container, Link, Menu, MenuItem } from "@mui/material"
import { useState } from "react"
import { gql, useMutation, useQuery } from "@apollo/client"

import { t } from "../lib/i18n"
import { MessagesContext } from "./BasicPage"

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

const USER_QUERY = gql`
  query UserQuery {
    me {
      id
      fullName
      avatar {
        imageSource
      }
    }
  }
`

type HeaderUser = {
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
  company?: Company
}

type User = {
  id: string
  fullName: string
  avatar: {
    imageSource: string
  }
}

type UserResult = {
  me: User
}

type UserDTO = UserResult | undefined

const SEND_API_TOKEN_MUTATION = gql`
  mutation SendAuthToken($companyId: Int!) {
    sendAuthToken(companyId: $companyId) {
      statusMessage
    }
  }
`

const normalizeUser = (data: UserDTO): HeaderUser => ({
  id: data?.me.id || "",
  fullName: data?.me.fullName || "",
  avatarSource: data?.me.avatar.imageSource || "",
})

const Header = ({ company }: HeaderProps) => {
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const handleClose = () => setAnchorEl(null)
  const { data: userData } = useQuery<UserDTO>(USER_QUERY)
  const user = normalizeUser(userData)
  const { pushMessage } = useContext(MessagesContext)

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
