import { Box, Container, Link } from "@mui/material"

const Footer = () => {
  return (
    <Box sx={{ py: 2, backgroundColor: "primary.main" }}>
      <Container maxWidth="xl">
        <Link href="/" sx={{ display: "block" }}>
          <img
            src="https://res.cloudinary.com/taller-digital/image/upload/v1599220860/2_taller_branco_horizontal.png"
            alt="Taller Logo"
            height={64}
          />
        </Link>
      </Container>
    </Box>
  )
}

export default Footer
