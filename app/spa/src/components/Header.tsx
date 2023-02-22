import { useContext } from "react"
import {
  Avatar,
  Box,
  Container,
  Divider,
  Link,
  Menu,
  MenuItem,
} from "@mui/material"
import { useState } from "react"
import { gql, useMutation } from "@apollo/client"

import { Company } from "../modules/company/company.types"
import { MessagesContext } from "../contexts/MessageContext"
import { MeContext } from "../contexts/MeContext"
import { useTranslation } from "react-i18next"
import User from "../modules/user/user.types"

type HeaderUser = {
  id: string
  avatarSource: string
  fullName: string
  companies: Companies[]
  admin: boolean
}

type Companies = Pick<Company, "id" | "name" | "slug">

const SEND_API_TOKEN_MUTATION = gql`
  mutation SendAuthToken($companyId: Int!) {
    sendAuthToken(companyId: $companyId) {
      statusMessage
    }
  }
`

const normalizeUser = (user?: User): HeaderUser => ({
  id: user?.id || "",
  fullName: user?.fullName || "",
  avatarSource: user?.avatar?.imageSource || "",
  companies: user?.companies || [],
  admin: user?.admin || false,
})

const Header = () => {
  const { t } = useTranslation(["header"])
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const handleClose = () => setAnchorEl(null)
  const { me } = useContext(MeContext)
  const company = me?.currentCompany
  const user = normalizeUser(me)
  const { pushMessage } = useContext(MessagesContext)

  const [sendAuthTokenMutation] = useMutation(SEND_API_TOKEN_MUTATION, {
    update: () =>
      pushMessage({
        text: t("token_success_message"),
        severity: "info",
      }),
  })

  const buildLinks = (companySlug: string) => [
    {
      name: company?.name,
      href: `/companies/${companySlug}`,
    },
    { name: t("teams"), href: `/companies/${companySlug}/teams` },
    { name: t("team_members"), href: `/companies/${companySlug}/team_members` },
    { name: t("customers"), href: `/companies/${companySlug}/customers` },
    { name: t("products"), href: `/companies/${companySlug}/products` },
    { name: t("initiatives"), href: `/companies/${companySlug}/initiatives` },
    { name: t("projects"), href: `/companies/${companySlug}/projects` },
    { name: t("demands"), href: `/companies/${companySlug}/demands` },
    { name: t("tasks"), href: `/companies/${companySlug}/tasks` },
    {
      name: t("demand_blocks"),
      href: `/companies/${companySlug}/demand_blocks`,
    },
    { name: t("flow_events"), href: `/companies/${companySlug}/flow_events` },
  ]

  return (
    <Box py={1} sx={{ backgroundColor: "primary.main" }}>
      <Container maxWidth="xl">
        <Box
          display="flex"
          alignItems="center"
          justifyContent="space-between"
          data-testid="main-menu"
        >
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
                key={`${link.name}--${index}`}
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
              <MenuItem
                key="userMenu.myAccount"
                component="a"
                href={`/users/${user.id}/edit`}
              >
                {t("userMenu.myAccount")}
              </MenuItem>
            )}
            <MenuItem
              key="userMenu.turnOnNotifications"
              component="a"
              href="/users/activate_email_notifications"
            >
              {t("userMenu.turnOnNotifications")}
            </MenuItem>
            {company && (
              <>
                <Divider />
                <MenuItem
                  key="sendAuthTokenMutation"
                  onClick={() =>
                    sendAuthTokenMutation({
                      variables: { companyId: Number(company.id) },
                    })
                  }
                  component="a"
                >
                  Solicitar API Token
                </MenuItem>
                <Divider />
                {user.companies.length > 1 ? (
                  <>
                    {user.companies.map((company) => (
                      <MenuItem
                        component="a"
                        href={`/companies/${company.slug}`}
                      >
                        {company.name}
                      </MenuItem>
                    ))}
                  </>
                ) : (
                  <>
                    <MenuItem component="a" href={`/companies/${company.slug}`}>
                      {company.name}
                    </MenuItem>
                    <Divider />
                  </>
                )}
              </>
            )}
            {user.admin && (
              <>
                <MenuItem
                  key="userMenu.adminDashboard"
                  component="a"
                  href="/users/admin_dashboard"
                >
                  {t("userMenu.adminDashboard")}
                </MenuItem>
                <Divider />
              </>
            )}

            <MenuItem
              key="userMenu.logout"
              component="a"
              href="/users/sign_out"
            >
              {t("userMenu.logout")}
            </MenuItem>
          </Menu>
        </Box>
      </Container>
    </Box>
  )
}

export default Header
