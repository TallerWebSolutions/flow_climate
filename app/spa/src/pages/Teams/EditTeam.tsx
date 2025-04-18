import { gql, useMutation, useQuery } from "@apollo/client"
import {
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
} from "@mui/material"
import { useContext } from "react"
import { useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"
import { useNavigate, useParams } from "react-router-dom"
import BasicPage from "../../components/BasicPage"
import { MessagesContext } from "../../contexts/MessageContext"
import { MeContext } from "../../contexts/MeContext"
import { Team } from "../../modules/team/team.types"
import { User } from "../../modules/user/user.types"

type TeamDTO = {
  me: User
  team: Team
}

export const TEAM_QUERY = gql`
  query Team($teamId: ID!) {
    team(id: $teamId) {
      id
      name
      maxWorkInProgress
    }
  }
`

type UpdateTeamDTO = {
  updateTeam: {
    id: number
    statusMessage: string
    company: {
      slug: string
    }
  }
}

const UPDATE_TEAM_MUTATION = gql`
  mutation EditTeam($teamId: String!, $name: String!, $wip: Int!) {
    updateTeam(teamId: $teamId, name: $name, maxWorkInProgress: $wip) {
      id
      statusMessage
      company {
        slug
      }
    }
  }
`

const EditTeam = () => {
  const { t } = useTranslation(["teams"])
  const { teamId } = useParams()
  const { pushMessage } = useContext(MessagesContext)
  const navigate = useNavigate()

  const { data, loading } = useQuery<TeamDTO>(TEAM_QUERY, {
    variables: {
      teamId: Number(teamId),
    },
  })

  const [updateTeam] = useMutation<UpdateTeamDTO>(UPDATE_TEAM_MUTATION, {
    update: (_, { data }) => {
      const newTeamID = data?.updateTeam.id
      const companySlug = data?.updateTeam.company.slug
      const mutationResult = data?.updateTeam.statusMessage === "SUCCESS"

      pushMessage({
        text: mutationResult
          ? t("edit_team.edit_team_message_success")
          : t("edit_team.edit_team_message_fail"),
        severity: mutationResult ? "success" : "error",
      })

      navigate(`/companies/${companySlug}/teams/${newTeamID}`)
    },
  })

  const { register, handleSubmit } = useForm()
  const { me } = useContext(MeContext)

  const team = data?.team
  const teamID = data?.team.id
  const teamMaxWip = data?.team.maxWorkInProgress
  const teamName = team?.name
  const company = me?.currentCompany
  const companySlug = company?.slug
  const breadcrumbsLinks = [
    {
      name: company?.name || "",
      url: `/companies/${companySlug}`,
    },
    { name: teamName || "", url: `/companies/${companySlug}/teams/${teamID}` },
    {
      name: t("edit_team.edit_team"),
    },
  ]

  const handleEditTeam = (data: any) => {
    const { teamName, teamMaxWip } = data

    updateTeam({
      variables: {
        teamId: String(teamID),
        name: teamName,
        wip: Number(teamMaxWip),
      },
    })
  }

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} loading={loading}>
      <form onSubmit={handleSubmit(handleEditTeam)}>
        <FormGroup
          sx={{
            display: "grid",
            gridTemplateColumns: "repeat(2, 1fr)",
            gridColumnGap: "30px",
          }}
        >
          <FormControl>
            <InputLabel htmlFor="teamName">
              {t("edit_team.edit_team_name")} *
            </InputLabel>

            <Input defaultValue={teamName} {...register("teamName")} />
          </FormControl>

          <FormControl>
            <InputLabel htmlFor="teamMaxWip">
              {t("edit_team.edit_team_max_wip")} *
            </InputLabel>

            <Input
              defaultValue={teamMaxWip}
              type="number"
              {...register("teamMaxWip")}
            />
          </FormControl>
        </FormGroup>

        <Button sx={{ mt: 2 }} variant="contained" type="submit">
          {t("edit_team_button")}
        </Button>
      </form>
    </BasicPage>
  )
}

export default EditTeam
