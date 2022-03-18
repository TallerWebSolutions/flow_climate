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

type LoggedUserDTO = {
  me: User
}

export const LOGGED_USER_QUERY = gql`
  query LoggedUser {
    me {
      language
      currentCompany {
        id
        name
        slug
      }
    }
  }
`

type CreateTeamDTO = {
  createTeam: {
    id: number
    statusMessage: string
    company: {
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

const CreateTeam = () => {
  const { t, i18n } = useTranslation(["teams"])
  const { pushMessage } = useContext(MessagesContext)
  const { data, loading } = useQuery<LoggedUserDTO>(LOGGED_USER_QUERY)
  const [createTeam] = useMutation<CreateTeamDTO>(CREATE_TEAM_MUTATION, {
    update: (_, { data }) => {
      const newTeamID = data?.createTeam.id
      const companySlug = data?.createTeam.company.slug
      const mutationResult = data?.createTeam.statusMessage === "SUCCESS"

      pushMessage({
        text: mutationResult
          ? t("create_team.create_team_message_success")
          : t("create_team.create_team_message_fail"),
        severity: mutationResult ? "success" : "error",
      })

      setTimeout(function () {
        window.location.assign(`/companies/${companySlug}/teams/${newTeamID}`)
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

  const company = data?.me.currentCompany!
  const companyName = company.name
  const companyUrl = company.slug
  const breadcrumbsLinks = [
    { name: capitalizeFirstLetter(companyName!), url: companyUrl! },
    {
      name: t("create_team.new_team"),
    },
  ]

  const handleCreateNewTeam = (data: any) => {
    const { teamName, teamMaxWip } = data

    createTeam({
      variables: {
        name: teamName,
        wip: Number(teamMaxWip),
      },
    })
  }

  return (
    <BasicPage company={company} breadcrumbsLinks={breadcrumbsLinks}>
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

export default CreateTeam
