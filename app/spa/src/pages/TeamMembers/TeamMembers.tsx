import { useContext } from "react"
import { useTranslation } from "react-i18next"
import CheckCircleIcon from "@mui/icons-material/CheckCircle"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/Table"
import { MeContext } from "../../contexts/MeContext"
import { gql, useQuery } from "@apollo/client"
import { Team } from "../../modules/team/team.types"
import { Backdrop, CircularProgress } from "@mui/material"

const TEAM_MEMBERS_QUERY = gql`
  query TeamMembers($companyId: Int!) {
    teamMembers(companyId: $companyId) {
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

type TeamMember = {
  name: string
  jiraAccountUserEmail: string
  startDate: string
  endDate: string
  billable: boolean
  teams: Team[]
}

type TeamMembersDTO = {
  teamMembers: TeamMember[]
}

const TeamMembers = () => {
  const { t } = useTranslation(["teamMembers"])
  const { me } = useContext(MeContext)
  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const companyId = me?.currentCompany?.id
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
    t("teamMembers.columns.status.title"),
  ]
  const { data, loading } = useQuery<TeamMembersDTO>(TEAM_MEMBERS_QUERY, {
    variables: { companyId: Number(companyId) },
  })
  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const teamMembers =
    data?.teamMembers.map((teamMember) => [
      teamMember.name,
      teamMember.teams.map((team) => team.name).join(", "),
      teamMember.jiraAccountUserEmail,
      teamMember.startDate,
      teamMember.endDate,
      teamMember.billable ? <CheckCircleIcon color="primary" /> : "",
      teamMember.endDate
        ? t("teamMembers.columns.status.active")
        : t("teamMembers.columns.status.inactive"),
    ]) || []

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks}>
      <Table headerCells={membersColumns} rows={teamMembers} />
    </BasicPage>
  )
}

export default TeamMembers
