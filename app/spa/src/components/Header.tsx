import { Box, Container, Link } from "@mui/material";

const buildLinks = (companyName: string) => ([
  {name: 'Taller', href: `/companies/${companyName}`},
  {name: 'Clientes', href: `/companies/${companyName}/customers`},
  {name: 'Produtos', href: `/companies/${companyName}/products`},
  {name: 'Projetos', href: `/companies/${companyName}/projects`},
  {name: 'Demandas', href: `/companies/${companyName}/demands`},
  {name: 'Bloqueios', href: `/companies/${companyName}/demand_blocks`},
  {name: 'Eventos', href: `/companies/${companyName}/flow_events`},
])

const Header = ({companyName}: {companyName: string}) => <Box bgcolor="primary.dark" py={1}>
  <Container>
    <Box display='flex' alignItems="center">
      <img src="/taller_logo.png" alt="Taller Logo" height={64} />
      {buildLinks(companyName).map((link, index) => (
        <Link sx={{textDecoration: 'none'}} px={2} key={link.name + index} href={link.href} color="primary.contrastText">{link.name}</Link>
      ))}
    </Box>
  </Container>
</Box>

export default Header
