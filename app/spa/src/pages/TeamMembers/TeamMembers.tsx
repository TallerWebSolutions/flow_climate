import { useContext } from "react"
import { useTranslation } from "react-i18next"
import CheckIcon from "@mui/icons-material/Check"
import EditOutlinedIcon from "@mui/icons-material/EditOutlined"
import {
  Box,
  Button,
  FormControl,
  InputLabel,
  Link,
  MenuItem,
  Select,
} from "@mui/material"
import { Link as RouterLink, useSearchParams } from "react-router-dom"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { gql, useMutation, useQuery } from "@apollo/client"
import { TeamMember } from "../../modules/teamMember/teamMember.types"
import { SelectChangeEvent } from "@mui/material/Select/SelectInput"
import DeleteOutlineOutlinedIcon from "@mui/icons-material/DeleteOutlineOutlined"
import { useConfirm } from "material-ui-confirm"
import { MessagesContext } from "../../contexts/MessageContext"

const TEAM_MEMBERS_QUERY = gql`
  query TeamMembers($companyId: Int!, $active: Boolean!) {
    teamMembers(companyId: $companyId, active: $active) {
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

const DELETE_TEAM_MEMBER_MUTATION = gql`
  mutation DeleteTeamMember($teamMemberId: ID!) {
    deleteTeamMember(teamMemberId: $teamMemberId) {
      statusMessage
    }
  }
`

type TeamMembersDTO = {
  teamMembers: TeamMember[]
}

type DeleteTeamMemberTypeDTO = {
  deleteTeamMember: {
    statusMessage: string
  }
}

const TeamMembers = () => {
  const { t } = useTranslation(["teamMembers"])
  const { me } = useContext(MeContext)
  const [searchParams, setSearchParams] = useSearchParams()
  const { pushMessage } = useContext(MessagesContext)
  const handleChangeActiveMembers = (event: SelectChangeEvent) =>
    setSearchParams((prev) => {
      prev.set("activeMembers", event.target.value)
      return prev
    })
  const companySlug = me?.currentCompany?.slug
  const companyUrl = `/companies/${companySlug}`
  const companyId = me?.currentCompany?.id
  const activeMembers = searchParams.get("activeMembers") !== "false"
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("list.title"),
    },
  ]

  const [deleteTeamMember] = useMutation<DeleteTeamMemberTypeDTO>(
    DELETE_TEAM_MEMBER_MUTATION,
    {
      update: (_, { data }) => {
        const mutationResult =
          data?.deleteTeamMember.statusMessage === "SUCCESS"

        pushMessage({
          text: mutationResult ? "SUCCESS" : "FAIL",
          severity: mutationResult ? "success" : "error",
        })
      },
      refetchQueries: [{ query: TEAM_MEMBERS_QUERY }],
    }
  )

  const deleteMemberConfirmationModal = useConfirm()

  function handleOnDeleteMember(id: string) {
    deleteMemberConfirmationModal({
      title: t("delete.confirm.title"),
      description: t("delete.confirm.body"),
    }).then(() => {
      deleteTeamMember({
        variables: { teamMemberId: id },
      })
    })
  }

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
    variables: { companyId: Number(companyId), active: activeMembers },
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
      teamMember.startDate || "",
      teamMember.endDate || "",
      teamMember.billable ? <CheckIcon color="primary" /> : "",
      teamMember.endDate
        ? t("columns.status.inactive")
        : t("columns.status.active"),
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
        }}
      >
        <RouterLink to={`${companyUrl}/team_members/${teamMember.id}/edit`}>
          <EditOutlinedIcon color="primary" />
        </RouterLink>

        <Button onClick={() => handleOnDeleteMember(teamMember.id)}>
          <DeleteOutlineOutlinedIcon color={"primary"} />
        </Button>
      </Box>,
    ]) || []

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} loading={loading}>
      <FormControl sx={{ minWidth: 240 }}>
        <InputLabel id="active-members-select">
          {t("list.statusSelectLabel")}
        </InputLabel>
        <Select
          autoWidth
          labelId="active-members-select"
          label={t("list.statusSelectLabel")}
          onChange={handleChangeActiveMembers}
          defaultValue={JSON.stringify(activeMembers)}
        >
          <MenuItem value="true">{t("columns.status.active")}</MenuItem>
          <MenuItem value="false">{t("columns.status.inactive")}</MenuItem>
        </Select>
      </FormControl>

      <Table headerCells={membersColumns} rows={teamMembers} />
    </BasicPage>
  )
}

export default TeamMembers
