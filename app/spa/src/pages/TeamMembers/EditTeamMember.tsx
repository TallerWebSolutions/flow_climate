import {
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Box,
  Button,
  Checkbox,
} from "@mui/material"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { FieldValues, useForm } from "react-hook-form"
import { useParams, Link } from "react-router-dom"
import { gql, useQuery, useMutation } from "@apollo/client"

import BasicPage from "../../components/BasicPage"
import { MeContext } from "../../contexts/MeContext"

const FORM_VALUES_QUERY = gql`
  query EditTeamMemberFormValues($teamMemberId: ID!) {
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
    }
  }
`

const EDIT_TEAM_MEMBER_MUTATION = gql`
  mutation EditTeamMember(
    $id: ID!
    $name: String!
    $startDate: ISO8601Date!
    $endDate: ISO8601Date
    $jiraAccountUserEmail: String
    $jiraAccountId: String
    $billable: Boolean!
    $hoursPerMonth: Int!
    $monthlyPayment: Float
  ) {
    updateTeamMember(
      teamMemberId: $id
      name: $name
      startDate: $startDate
      endDate: $endDate
      jiraAccountUserEmail: $jiraAccountUserEmail
      jiraAccountId: $jiraAccountId
      billable: $billable
      hoursPerMonth: $hoursPerMonth
      monthlyPayment: $monthlyPayment
    ) {
      updatedTeamMember {
        id
        name
        startDate
        endDate
        jiraAccountUserEmail
        jiraAccountId
        billable
        hoursPerMonth
        monthlyPayment
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
  const [editTeamMember, { loading: mutationLoading }] = useMutation(
    EDIT_TEAM_MEMBER_MUTATION
  )

  const teamMember = data?.teamMember
  if (!teamMember) return <strong>{t("general.notFound")}</strong>

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const teamMembersUrl = `${companyUrl}/team_members`
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("list.title"),
      url: teamMembersUrl,
    },
    {
      name: t("edit.title"),
    },
  ]

  const handleEditTeamMember = (data: FieldValues) => {
    return editTeamMember({
      variables: {
        id: Number(teamMemberId),
        name: data.name,
        startDate: data.startDate,
        endDate: data.endDate.length ? data.endDate : null,
        jiraAccountUserEmail: data.jiraAccountUserEmail,
        jiraAccountId: data.jiraAccountId,
        billable: data.billable,
        hoursPerMonth: Number(data.hoursPerMonth),
        monthlyPayment: Number(data.monthlyPayment),
      },
    })
  }

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={t("edit.title")}
      loading={loading || mutationLoading}
    >
      <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4 }}>
        <form onSubmit={handleSubmit(handleEditTeamMember)}>
          <FormGroup>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="name">{t("columns.name")}</InputLabel>
              <Input
                {...register("name", { required: true })}
                defaultValue={teamMember.name}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="startDate" shrink>
                {t("columns.start")}
              </InputLabel>
              <Input
                {...register("startDate", { required: true })}
                type="date"
                defaultValue={teamMember.startDate}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="endDate" shrink>
                {t("columns.finish")}
              </InputLabel>
              <Input
                {...register("endDate")}
                type="date"
                defaultValue={teamMember.endDate}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="monthlyPayment">
                {t("columns.monthlyPayment")}
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
                {t("columns.hoursPerMonth")}
              </InputLabel>
              <Input
                {...register("hoursPerMonth", { required: true })}
                type="number"
                inputProps={{ step: "any" }}
                defaultValue={teamMember.hoursPerMonth}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="billable">
                {t("columns.billable")}
              </InputLabel>
              <Checkbox
                {...register("billable")}
                defaultChecked={teamMember.billable}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="jiraAccountUserEmail">
                {t("columns.jiraAccountUserEmail")}
              </InputLabel>
              <Input
                {...register("jiraAccountUserEmail")}
                defaultValue={teamMember.jiraAccountUserEmail}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="jiraAccountId">
                {t("columns.jiraAccountId")}
              </InputLabel>
              <Input
                {...register("jiraAccountId")}
                defaultValue={teamMember.jiraAccountId}
              />
            </FormControl>
            <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
              <Button type="submit" variant="contained" sx={{ marginRight: 2 }}>
                {t("edit.form.save")}
              </Button>
              <Button variant="outlined" component={Link} to={teamMembersUrl}>
                {t("edit.form.cancel")}
              </Button>
            </Box>
          </FormGroup>
        </form>
      </Box>
    </BasicPage>
  )
}

export default EditTeamMember
