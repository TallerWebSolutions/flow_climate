import { useTranslation } from "react-i18next"
import {
  FormControl,
  FormGroup,
  InputLabel,
  Input,
  Box,
  Button,
  Typography,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useMutation } from "@apollo/client"
import { Link, useParams, useNavigate } from "react-router-dom"

import { ProjectPage } from "../../components/Projects/ProjectPage"
import { FINANCIAL_REPORT_QUERY } from "./ProjectFinancialReport"

const CREATE_ADITIONAL_HOURS_MUTATION = gql`
  mutation CreateAdditionalHours(
    $projectId: ID!
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
  const { projectId, companySlug } = useParams()
  const { register, handleSubmit } = useForm()
  const navigate = useNavigate()
  const financialReportUrl = `/companies/${companySlug}/projects/${projectId}/financial_report`
  const [createAdditionalHours, { loading }] = useMutation(
    CREATE_ADITIONAL_HOURS_MUTATION,
    {
      refetchQueries: [
        {
          query: FINANCIAL_REPORT_QUERY,
          variables: {
            projectId,
          },
        },
      ],
      update: () => navigate(financialReportUrl),
    }
  )
  const handleCreateAdditionalHours = (data: FieldValues) =>
    createAdditionalHours({
      variables: {
        projectId,
        hours: Number(data.hours),
        obs: data.obs,
        eventDate: data.eventDate,
      },
    })

  return (
    <ProjectPage pageName={t("registerAdditionalHours")} loading={loading}>
      <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4 }}>
        <Typography component="h2" variant="h5" sx={{ marginBottom: 4 }}>
          {t("registerAdditionalHours")}
        </Typography>
        <form onSubmit={handleSubmit(handleCreateAdditionalHours)}>
          <FormGroup>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel shrink htmlFor="eventDate">
                {t("form.eventDate")} *
              </InputLabel>
              <Input
                {...register("eventDate", { required: true })}
                type="date"
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="hours">{t("form.hours")} *</InputLabel>
              <Input
                {...register("hours", { required: true })}
                type="number"
                inputProps={{ step: "any" }}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="obs">{t("form.obs")} *</InputLabel>
              <Input
                {...register("obs", { required: true })}
                multiline
                rows={6}
              />
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
