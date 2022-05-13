import { useContext } from "react"
import { useTranslation } from "react-i18next"
import CheckIcon from "@mui/icons-material/Check"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/Table"
import { MeContext } from "../../contexts/MeContext"
import { gql, useQuery } from "@apollo/client"
import { Team } from "../../modules/team/team.types"
import { Backdrop, CircularProgress } from "@mui/material"
import { Link } from "react-router-dom"

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

type TeamMember = {
  id: string
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
      name: t("list.title"),
    },
  ]

  const membersColumns = [
    t("list.columns.name"),
    t("list.columns.teams"),
    t("list.columns.email"),
    t("list.columns.start"),
    t("list.columns.finish"),
    t("list.columns.billable"),
    t("list.columns.status.title"),
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
      teamMember.billable ? <CheckIcon color="primary" /> : "",
      teamMember.endDate
        ? t("list.columns.status.active")
        : t("list.columns.status.inactive"),
      <Link to={`${companyUrl}/team_members/${teamMember.id}/edit`}>
        <EditOutlinedIcon color="primary" />
      </Link>,
    ]) || []

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks}>
      <Table headerCells={membersColumns} rows={teamMembers} />
    </BasicPage>
  )
}

export default TeamMembers
