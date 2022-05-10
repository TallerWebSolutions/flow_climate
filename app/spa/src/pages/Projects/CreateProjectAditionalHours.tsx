import { useTranslation } from "react-i18next"
import {
  FormControl,
  FormGroup,
  InputLabel,
  Input,
  Box,
  Button,
  Typography,
  Backdrop,
  CircularProgress,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useMutation } from "@apollo/client"
import { Link, useParams, useNavigate } from "react-router-dom"

import { ProjectPage } from "../../components/ProjectPage"

const CREATE_ADITIONAL_HOURS_MUTATION = gql`
  mutation CreateAdditionalHours(
    $projectId: Int!
    $hours: Float!
    $obs: String!
    $eventDate: ISO8601Date!
  ) {
    createProjectAdditionalHours(
      projectId: $projectId
      hours: $hours
      hoursType: 0
      obs: $obs
      eventDate: $eventDate
    ) {
      statusMessage
    }
  }
`

const CreateProjectAditionalHours = () => {
  const { t } = useTranslation("projectFinancialReport")
  const { projectId, companyNickName } = useParams()
  const { register, handleSubmit } = useForm()
  const navigate = useNavigate()
  const financialReportUrl = `/companies/${companyNickName}/projects/${projectId}/financial_report`
  const [createAdditionalHours, { loading, error }] = useMutation(
    CREATE_ADITIONAL_HOURS_MUTATION,
    {
      update: () => navigate(financialReportUrl),
    }
  )
  const handleCreateAdditionalHours = (data: FieldValues) => {
    createAdditionalHours({
      variables: {
        projectId: Number(projectId),
        hours: Number(data.hours),
        obs: data.obs,
        eventDate: data.eventDate,
      },
    })
  }

  if (error) {
    // eslint-disable-next-line no-console
    console.error(error)
  }
  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <ProjectPage pageName={t("registerAdditionalHours")}>
      <Typography component="h2">{t("registerAdditionalHours")}</Typography>
      <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4 }}>
        <form onSubmit={handleSubmit(handleCreateAdditionalHours)}>
          <FormGroup>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="eventDate">
                {t("form.eventDate")} *
              </InputLabel>
              <Input {...register("eventDate")} type="date" />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="hours">{t("form.hours")} *</InputLabel>
              <Input
                {...register("hours")}
                type="number"
                inputProps={{ step: "any" }}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="obs">{t("form.obs")} *</InputLabel>
              <Input {...register("obs")} multiline rows={6} />
            </FormControl>
          </FormGroup>
          <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
            <Button type="submit" variant="contained" sx={{ marginRight: 2 }}>
              {t("form.save")}
            </Button>
            <Button variant="outlined" component={Link} to={financialReportUrl}>
              {t("form.cancel")}
            </Button>
          </Box>
        </form>
      </Box>
    </ProjectPage>
  )
}

export default CreateProjectAditionalHours
