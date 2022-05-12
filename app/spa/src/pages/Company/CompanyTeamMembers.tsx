import { useContext } from "react"
import { useTranslation } from "react-i18next"

import BasicPage from "../../components/BasicPage"
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

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks}>
      <h1>CompanyTeamMembers</h1>
    </BasicPage>
  )
}

export default CompanyTeamMembers
