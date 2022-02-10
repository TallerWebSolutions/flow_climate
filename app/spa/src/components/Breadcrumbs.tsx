import {
  Breadcrumbs as MUIBreadcrumbs,
  Box,
  Link,
  Typography,
} from "@mui/material"

type BreadcrumbsLink = {
  name: string
  url: string
}

type BreadcrumbsProps = {
  links: BreadcrumbsLink[]
  currentPageName: string
}

const Breadcrumbs = ({ links, currentPageName }: BreadcrumbsProps) => (
  <Box py={3}>
    <MUIBreadcrumbs aria-label="breadcrumb">
      {links.map((link) => (
        <Link underline="hover" color="inherit" href={link.url}>
          {link.name}
        </Link>
      ))}
      <Typography color="text.primary">{currentPageName}</Typography>
    </MUIBreadcrumbs>
  </Box>
)

export default Breadcrumbs
