import { gql, useMutation } from "@apollo/client"
import {
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
} from "@mui/material"
import { useContext } from "react"
import { FieldValues, useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"
import BasicPage from "../../components/BasicPage"
import { MessagesContext } from "../../contexts/MessageContext"
import { MeContext } from "../../contexts/MeContext"
import { useNavigate } from "react-router-dom"

const CreateTeam = () => {
  const { t } = useTranslation(["teams"])
  const { pushMessage } = useContext(MessagesContext)
  const { me } = useContext(MeContext)
  const navigate = useNavigate()
  const [createTeam] = useMutation<CreateTeamDTO>(CREATE_TEAM_MUTATION, {
    update: (_, { data }) => {
      const newTeamID = data?.createTeam?.id
      const companySlug = data?.createTeam?.company?.slug
      const mutationResult = data?.createTeam?.statusMessage === "SUCCESS"

      pushMessage({
        text: mutationResult
          ? t("create_team.create_team_message_success")
          : t("create_team.create_team_message_fail"),
        severity: mutationResult ? "success" : "error",
      })

      navigate(`/companies/${companySlug}/teams/${newTeamID}`)
    },
  })

  const { register, handleSubmit } = useForm()

  const company = me?.currentCompany
  const companyName = company?.name
  const companyUrl = `/companies/${company?.slug}`
  const breadcrumbsLinks = [
    { name: companyName || "", url: companyUrl },
    {
      name: t("teams_list"),
      url: `${companyUrl}/teams`,
    },
    {
      name: t("create_team.new_team"),
    },
  ]

  const handleCreateNewTeam = (data: FieldValues) => {
    const { teamName, teamMaxWip } = data

    createTeam({
      variables: {
        name: teamName,
        wip: Number(teamMaxWip),
      },
    })
  }

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks}>
      <form onSubmit={handleSubmit(handleCreateNewTeam)}>
        <FormGroup
          sx={{
            display: "grid",
            gridTemplateColumns: "repeat(2, 1fr)",
            gridColumnGap: "30px",
          }}
        >
          <FormControl>
            <InputLabel htmlFor="teamName">
              {t("create_team.new_team_name")} *
            </InputLabel>

            <Input {...register("teamName")} />
          </FormControl>

          <FormControl>
            <InputLabel htmlFor="teamMaxWip">
              {t("create_team.new_team_max_wip")} *
            </InputLabel>

            <Input type="number" {...register("teamMaxWip")} />
          </FormControl>
        </FormGroup>

        <Button sx={{ mt: 2 }} variant="contained" type="submit">
          {t("create_team_button")}
        </Button>
      </form>
    </BasicPage>
  )
}

type CreateTeamDTO = {
  createTeam?: {
    id: number
    statusMessage: string
    company?: {
      slug: string
    }
  }
}

const CREATE_TEAM_MUTATION = gql`
  mutation CreateTeam($name: String!, $wip: Int!) {
    createTeam(name: $name, maxWorkInProgress: $wip) {
      id
      statusMessage
      company {
        slug
      }
    }
  }
`

export default CreateTeam
