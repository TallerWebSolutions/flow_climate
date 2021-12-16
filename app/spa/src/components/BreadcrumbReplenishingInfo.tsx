import {Breadcrumbs, Link, Typography} from "@mui/material";

type BreadcrumbReplenishing = {
    companyName: string,
    companyUrl: string,
    teamName: string,
    teamUrl: string
}

type BreadcrumbReplenishingProps = {
    replenishingBreadcrumb: BreadcrumbReplenishing
}

const BreadcrumbReplenishingInfo = ({ replenishingBreadcrumb }: BreadcrumbReplenishingProps) => (
    <Breadcrumbs aria-label="breadcrumb">
        <Link
            underline="hover"
            color="inherit"
            href={replenishingBreadcrumb.companyUrl}
        >
            {replenishingBreadcrumb.companyName}
        </Link>
        <Link
            underline="hover"
            color="inherit"
            href={replenishingBreadcrumb.teamUrl}
        >
            {replenishingBreadcrumb.teamName}
        </Link>
        <Typography color="text.primary">
            Replenishing
        </Typography>
    </Breadcrumbs>
)

export default BreadcrumbReplenishingInfo

