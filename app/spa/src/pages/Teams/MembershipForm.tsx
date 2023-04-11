import { useParams } from "react-router-dom"
import { gql, useQuery } from "@apollo/client"
import { useContext } from "react"

import BasicPage from "../../components/BasicPage"
import { Team } from "../../modules/team/team.types"
import { MeContext } from "../../contexts/MeContext"

const MembershipForm = () => {
  const params = useParams()
  const { me } = useContext(MeContext)
  const { data, loading } = useQuery<MembershipFormDTO>(MEMBERSHIP_FORM_QUERY)

  const team = data?.team
  const teamId = params.teamId || ""
  const company = me?.currentCompany
  const companyUrl = `/companies/${company?.slug}`
  const breadcrumbsLinks = [
    { name: company?.name || "", url: companyUrl || "" },
    { name: team?.name || "", url: `${companyUrl}/teams/${teamId}` },
  ]

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    ></BasicPage>
  )
}

const MEMBERSHIP_FORM_QUERY = gql`
  query MembershipForm($teamId: Int!) {
    team(id: $teamId) {
      id
    }
  }
`

type MembershipFormDTO = {
  team?: Team
}

export default MembershipForm
