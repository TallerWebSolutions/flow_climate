import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"

import { MeContext } from "../../contexts/MeContext"
import BasicPage from "../../components/BasicPage"

const TEAM_MEMBER_QUERY = gql`
  query TeamMember($id: Int!) {
    teamMember(id: $id) {
      id
      name
    }
  }
`

const TeamMemberDashboard = () => {
  const { t } = useTranslation(["teamMembers"])
  const { me } = useContext(MeContext)
  const { teamMemberId } = useParams()
  const { data, loading } = useQuery(TEAM_MEMBER_QUERY, {
    variables: {
      id: Number(teamMemberId),
    },
  })
  const companySlug = me?.currentCompany?.slug
  const companyUrl = `/companies/${companySlug}`
  const teamMemberName = ""
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("list.title"),
      url: `${companyUrl}/team_members`,
    },
    {
      name: teamMemberName,
    },
  ]
  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={teamMemberName}
      loading={loading}
    />
  )
}

export default TeamMemberDashboard
