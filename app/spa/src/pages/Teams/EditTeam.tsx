import { gql, useMutation, useQuery } from "@apollo/client"
import {
  Backdrop,
  Button,
  CircularProgress,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
} from "@mui/material"
import { useForm } from "react-hook-form"
import { useContext, useEffect } from "react"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import { MessagesContext } from "../../contexts/MessageContext"
import { capitalizeFirstLetter } from "../../lib/func"
import User from "../../modules/user/user.types"
import { Team } from "../../modules/team/team.types"

type LoggedUserDTO = {
  me: User
  team: Team
}

export const TEAM_QUERY = gql`
  query Team($id: String!) {
    team(id: $id) {
      id
      name
    }

    me {
      language
      currentCompany {
        name
        slug
      }
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
      statusMessage
      id
      statusMessage
      company {
        slug
      }
    }
  }
`

const EditTeam = () => {
  const { t, i18n } = useTranslation(["teams"])
  const { pushMessage } = useContext(MessagesContext)
  const { data, loading } = useQuery<LoggedUserDTO>(TEAM_QUERY)
  const [updateTeam] = useMutation<UpdateTeamDTO>(UPDATE_TEAM_MUTATION, {
    update: (_, { data }) => {
      const newTeamID = data?.updateTeam.id
      const company = data?.updateTeam.company.slug
      const mutationResult = data?.updateTeam.statusMessage === "SUCCESS"

      pushMessage({
        text: mutationResult
          ? t("edit_team.edit_team_message_success")
          : t("edit_team.edit_team_message_fail"),
        severity: mutationResult ? "success" : "error",
      })

      setTimeout(function () {
        window.location.assign(`/companies/${company}/teams/${newTeamID}`)
      }, 2000)
    },
  })

  const { register, handleSubmit } = useForm()

  useEffect(() => {
    if (!loading) i18n.changeLanguage(data?.me.language)
  }, [loading, data, i18n])

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const team = data?.team!
  const company = data?.me.currentCompany!
  const companyName = company.name
  const companyUrl = company.slug
  const breadcrumbsLinks = [
    { name: capitalizeFirstLetter(companyName!), url: companyUrl! },
    {
      name: t("edit_team.new_team"),
    },
  ]

  const handleCreateNewTeam = (data: any) => {
    const { teamName, teamMaxWip } = data

    console.log(data)

    updateTeam({
      variables: {
        teamId: Number(team.id),
        name: teamName,
        wip: Number(teamMaxWip),
      },
    })
  }

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks}>
      <form onSubmit={handleSubmit(handleCreateNewTeam)}>
        <FormGroup sx={{ flexWrap: "wrap" }} row={true}>
          <FormControl sx={{ flex: "1 0 45%", mr: 1 }}>
            <InputLabel htmlFor="teamName">
              {t("edit_team.new_team_name")} *
            </InputLabel>

            <Input {...register("teamName")} />
          </FormControl>

          <FormControl sx={{ flex: "1 0 45%", ml: 1 }}>
            <InputLabel htmlFor="teamMaxWip">
              {t("edit_team.new_team_max_wip")} *
            </InputLabel>

            <Input type="number" {...register("teamMaxWip")} />
          </FormControl>

          <Button sx={{ mt: 2 }} variant="contained" type="submit">
            {t("create_team_button")}
          </Button>
        </FormGroup>
      </form>
    </BasicPage>
  )
}

export default EditTeam
