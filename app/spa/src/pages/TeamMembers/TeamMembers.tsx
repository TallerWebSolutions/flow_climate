import { useContext } from "react"
import { useTranslation } from "react-i18next"
import CheckIcon from "@mui/icons-material/Check"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"
import { Link } from "@mui/material"
import { Link as RouterLink } from "react-router-dom"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { gql, useQuery } from "@apollo/client"
import { TeamMember } from "../../modules/teamMember/teamMember.types"

const TEAM_MEMBERS_QUERY = gql`
  query TeamMembers($companyId: Int!) {
    teamMembers(companyId: $companyId) {
      id
      name
      jiraAccountUserEmail
      startDate
      endDate
      billable
      teams {
        name
      }
    }
  }
`

type TeamMembersDTO = {
  teamMembers: TeamMember[]
}

const TeamMembers = () => {
  const { t } = useTranslation(["teamMembers"])
  const { me } = useContext(MeContext)
  const companySlug = me?.currentCompany?.slug
  const companyUrl = `/companies/${companySlug}`
  const companyId = me?.currentCompany?.id
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("list.title"),
    },
  ]

  const membersColumns = [
    t("columns.name"),
    t("columns.teams"),
    t("columns.email"),
    t("columns.start"),
    t("columns.finish"),
    t("columns.billable"),
    t("columns.status.title"),
  ]

  const { data, loading } = useQuery<TeamMembersDTO>(TEAM_MEMBERS_QUERY, {
    variables: { companyId: Number(companyId) },
  })

  const teamMembers =
    data?.teamMembers.map((teamMember) => [
      <Link
        component={RouterLink}
        to={`/companies/${companySlug}/team_members/${teamMember.id}`}
      >
        {teamMember.name}
      </Link>,
      teamMember.teams.map((team) => team.name).join(", "),
      teamMember.jiraAccountUserEmail,
      teamMember.startDate,
      teamMember.endDate,
      teamMember.billable ? <CheckIcon color="primary" /> : "",
      teamMember.endDate
        ? t("columns.status.inactive")
        : t("columns.status.active"),
      <RouterLink to={`${companyUrl}/team_members/${teamMember.id}/edit`}>
        <EditOutlinedIcon color="primary" />
      </RouterLink>,
    ]) || []

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} loading={loading}>
      <Table headerCells={membersColumns} rows={teamMembers} />
    </BasicPage>
  )
}

export default TeamMembers
