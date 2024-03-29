import { Box } from "@mui/material"
import { useTranslation } from "react-i18next"
import { useLocation, useParams } from "react-router-dom"
import BasicPage, { BasicPageProps } from "../../../components/BasicPage"
import ActionMenu from "../../../components/menu/ActionMenu"
import { Tabs } from "../../../components/Tabs"

type TeamBasicPageProps = BasicPageProps

const TeamBasicPage = ({ children, ...props }: TeamBasicPageProps) => {
  const { pathname } = useLocation()
  const { teamId, companySlug } = useParams()
  const { t } = useTranslation("teams")
  const teamTabs = [
    {
      label: t("tabs.dashboard"),
      to: `/companies/${companySlug}/teams/${teamId}`,
    },
    {
      label: t("tabs.replenishing"),
      to: `/companies/${companySlug}/teams/${teamId}/replenishing_consolidations`,
    },
  ]
  const actions = [
    {
      name: t("actions.edit"),
      href: `/companies/${companySlug}/teams/${teamId}/edit`,
    },
    {
      name: t("actions.memberships"),
      href: `/companies/${companySlug}/teams/${teamId}/memberships`,
    },
  ]
  return (
    <BasicPage {...props} actions={<ActionMenu items={actions} />}>
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Tabs tabs={teamTabs} currentPath={pathname} />
      </Box>
      {children}
    </BasicPage>
  )
}

export default TeamBasicPage
