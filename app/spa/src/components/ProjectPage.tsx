import { Box } from "@mui/material"
import BasicPage, { BasicPageProps } from "./BasicPage"
import { Tab, Tabs } from "./Tabs"
import { useLocation } from "react-router-dom"

type ProjectPageProps = {
  tabs?: Tab[]
} & BasicPageProps

export const ProjectPage = ({
  children,
  title,
  breadcrumbsLinks,
  company,
  tabs,
}: ProjectPageProps) => {
  const { pathname } = useLocation()

  return (
    <BasicPage
      title={title}
      breadcrumbsLinks={breadcrumbsLinks}
      company={company}
    >
      <>
        {tabs && (
          <Box
            sx={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <Tabs tabs={tabs} currentPath={pathname} />
          </Box>
        )}
        {children}
      </>
    </BasicPage>
  )
}
