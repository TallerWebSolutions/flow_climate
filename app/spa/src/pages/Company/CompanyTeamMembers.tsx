import { useContext } from "react"
import { useTranslation } from "react-i18next"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/Table"
import { MeContext } from "../../contexts/MeContext"

const CompanyTeamMembers = () => {
  const { t } = useTranslation(["company"])
  const { me } = useContext(MeContext)
  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("teamMembers.title"),
    },
  ]

  const membersColumns = [
    t("teamMembers.columns.name"),
    t("teamMembers.columns.teams"),
    t("teamMembers.columns.email"),
    t("teamMembers.columns.start"),
    t("teamMembers.columns.finish"),
    t("teamMembers.columns.billable"),
    t("teamMembers.columns.status"),
  ]
  const teamMembers = [[]]

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks}>
      <Table headerCells={membersColumns} rows={teamMembers} />
    </BasicPage>
  )
}

export default CompanyTeamMembers
