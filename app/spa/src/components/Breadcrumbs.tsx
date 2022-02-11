import {
  Breadcrumbs as MUIBreadcrumbs,
  Box,
  Link,
  Typography,
} from "@mui/material"

export type BreadcrumbsLink = {
  name: string
  url: string
}

type BreadcrumbsProps = {
  links: BreadcrumbsLink[]
  currentPageName: string
}

const Breadcrumbs = ({ links, currentPageName }: BreadcrumbsProps) => (
  <Box py={3} data-testid="breadcrumbs">
    <MUIBreadcrumbs aria-label="breadcrumb">
      {links.map((link, index) => (
        <Link
          underline="hover"
          color="inherit"
          href={link.url}
          key={`${link.name}--${index}`}
        >
          {link.name}
        </Link>
      ))}
      <Typography color="text.primary">{currentPageName}</Typography>
    </MUIBreadcrumbs>
  </Box>
)

export default Breadcrumbs
