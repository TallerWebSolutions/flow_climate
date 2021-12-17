import {Avatar, Box, Container, Link} from "@mui/material";

import {toImplementMessage} from "../pages/Replenishment";

const buildLinks = (companyName: string) => ([
  {name: 'Taller', href: `/companies/${companyName}`},
  {name: 'Clientes', href: `/companies/${companyName}/customers`},
  {name: 'Produtos', href: `/companies/${companyName}/products`},
  {name: 'Projetos', href: `/companies/${companyName}/projects`},
  {name: 'Demandas', href: `/companies/${companyName}/demands`},
  {name: 'Bloqueios', href: `/companies/${companyName}/demand_blocks`},
  {name: 'Eventos', href: `/companies/${companyName}/flow_events`},
])

type User = {
  avatarSource: string,
  fullName: string,
}

const Header = ({companyName, user}: {companyName: string, user: User}) => <Box bgcolor="primary.dark" py={1}>
  <Container>
    <Box display='flex' alignItems="center" justifyContent="space-between">
      <img src="https://res.cloudinary.com/taller-digital/image/upload/v1599220860/2_taller_branco_horizontal.png" alt="Taller Logo" height={64} />
      {buildLinks(companyName).map((link, index) => (
        <Link sx={{textDecoration: 'none'}} px={2} key={link.name + index} href={link.href} color="primary.contrastText">{link.name}</Link>
      ))}
      <Avatar alt={user.fullName} src={user.avatarSource} onClick={toImplementMessage}/>
    </Box>
  </Container>
</Box>

export default Header
