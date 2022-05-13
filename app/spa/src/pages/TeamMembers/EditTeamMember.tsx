import { FormControl, FormGroup, Input, InputLabel } from "@mui/material"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { useForm } from "react-hook-form"
import { useParams } from "react-router-dom"
import { Backdrop, CircularProgress } from "@mui/material"
import { gql, useQuery, useMutation } from "@apollo/client"

import BasicPage from "../../components/BasicPage"
import { MeContext } from "../../contexts/MeContext"

const FORM_VALUES_QUERY = gql`
  query EditTeamMemberFormValues($teamMemberId: Int!) {
    teamMember(id: $teamMemberId) {
      id
      name
      startDate
      endDate
      jiraAccountUserEmail
      jiraAccountId
      billable
      hoursPerMonth
      monthlyPayment
      teams {
        id
        name
      }
    }
  }
`

const EditTeamMember = () => {
  const { t } = useTranslation(["teamMembers"])
  const { teamMemberId } = useParams()
  const { me } = useContext(MeContext)
  const { register, handleSubmit } = useForm()
  const { data, loading } = useQuery(FORM_VALUES_QUERY, {
    variables: {
      teamMemberId: Number(teamMemberId),
    },
  })

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const teamMember = data?.teamMember
  if (!teamMember) return <strong>{t("teamMembers.notFound")}</strong>

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("list.title"),
      url: `${companyUrl}/team_members`,
    },
    {
      name: t("edit.title"),
    },
  ]

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} title={t("edit.title")}>
      <form>
        <FormGroup>
          <FormControl sx={{ marginBottom: 4 }}>
            <InputLabel htmlFor="name">{t("edit.form.name")}</InputLabel>
            <Input
              {...register("name", { required: true })}
              defaultValue={teamMember.name}
            />
          </FormControl>
          <FormControl sx={{ marginBottom: 4 }}>
            <InputLabel htmlFor="startDate" shrink>
              {t("edit.form.startDate")}
            </InputLabel>
            <Input
              {...register("startDate", { required: true })}
              type="date"
              defaultValue={teamMember.startDate}
            />
          </FormControl>
          <FormControl sx={{ marginBottom: 4 }}>
            <InputLabel htmlFor="endDate" shrink>
              {t("edit.form.endDate")}
            </InputLabel>
            <Input
              {...register("endDate", { required: true })}
              type="date"
              defaultValue={teamMember.endDate}
            />
          </FormControl>
          <FormControl sx={{ marginBottom: 4 }}>
            <InputLabel htmlFor="monthlyPayment">
              {t("edit.form.monthlyPayment")}
            </InputLabel>
            <Input
              {...register("monthlyPayment", { required: true })}
              type="number"
              inputProps={{ step: "any" }}
              defaultValue={teamMember.monthlyPayment}
            />
          </FormControl>
          <FormControl sx={{ marginBottom: 4 }}>
            <InputLabel htmlFor="hoursPerMonth">
              {t("edit.form.hoursPerMonth")}
            </InputLabel>
            <Input
              {...register("hoursPerMonth", { required: true })}
              type="number"
              inputProps={{ step: "any" }}
              defaultValue={teamMember.hoursPerMonth}
            />
          </FormControl>
        </FormGroup>
      </form>
    </BasicPage>
  )
}

export default EditTeamMember
