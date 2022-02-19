import { Breadcrumbs as MUIBreadcrumbs, Link, Typography } from "@mui/material"

export type BreadcrumbsLink = {
  name: string
  url?: string
}

type BreadcrumbsProps = {
  links: BreadcrumbsLink[]
}

const Breadcrumbs = ({ links }: BreadcrumbsProps) => (
  <MUIBreadcrumbs
    aria-label="breadcrumb"
    data-testid="breadcrumbs"
    sx={{ paddingY: 3 }}
  >
    {links.map((link, index) =>
      link.url ? (
        <Link
          underline="hover"
          color="inherit"
          href={link.url}
          key={`${link.name}--${index}`}
        >
          {link.name}
        </Link>
      ) : (
        <Typography color="text.primary" key={`${link.name}--${index}`}>
          {link.name}
        </Typography>
      )
    )}
  </MUIBreadcrumbs>
)

export default Breadcrumbs
