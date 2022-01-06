import { Avatar, Box, Container, Link, Menu, MenuItem } from "@mui/material"
import { useState } from "react"

const buildLinks = (companyName: string) => [
  { name: "Taller", href: `/companies/${companyName}` },
  { name: "Clientes", href: `/companies/${companyName}/customers` },
  { name: "Produtos", href: `/companies/${companyName}/products` },
  { name: "Projetos", href: `/companies/${companyName}/projects` },
  { name: "Demandas", href: `/companies/${companyName}/demands` },
  { name: "Bloqueios", href: `/companies/${companyName}/demand_blocks` },
  { name: "Eventos", href: `/companies/${companyName}/flow_events` },
]

type User = {
  id: string
  avatarSource: string
  fullName: string
}

type Company = {
  name: string
  slug: string
}

const Header = ({ company, user }: { company: Company; user: User }) => {
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const handleClose = () => setAnchorEl(null)

  return (
    <Box bgcolor="secondary.dark" py={1}>
      <Container>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Link href="/" sx={{ display: "block" }}>
            <img
              src="https://res.cloudinary.com/taller-digital/image/upload/v1599220860/2_taller_branco_horizontal.png"
              alt="Taller Logo"
              height={64}
            />
          </Link>
          {buildLinks(company.name).map((link, index) => (
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
          <Avatar
            alt={user.fullName}
            src={user.avatarSource}
            onClick={(e) => setAnchorEl(e.currentTarget)}
            sx={{ cursor: "pointer" }}
          />
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
            <MenuItem component="a" href={`/users/${user.id}/edit`}>
              Minha Conta
            </MenuItem>
            <MenuItem component="a" href="/users/activate_email_notifications">
              Ligar Notificações
            </MenuItem>
            <MenuItem component="a" href={`/companies/${company.slug}`}>
              {company.name}
            </MenuItem>
            <MenuItem component="a" href="/users/admin_dashboard">
              Admin Dashboard
            </MenuItem>
            <MenuItem component="a" href="/users/sign_out">
              Sair
            </MenuItem>
          </Menu>
        </Box>
      </Container>
    </Box>
  )
}

export default Header
