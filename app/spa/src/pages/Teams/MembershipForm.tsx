import { Link, useNavigate, useParams } from "react-router-dom"
import { gql, useMutation, useQuery } from "@apollo/client"
import { useContext } from "react"

import BasicPage from "../../components/BasicPage"
import { Membership, Team } from "../../modules/team/team.types"
import { MeContext } from "../../contexts/MeContext"
import {
  Box,
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Select,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"
import { MEMBERSHIP_TABLE_QUERY } from "./MembershipTable"

const MembershipForm = () => {
  const params = useParams()
  const { t } = useTranslation("membership")
  const { me } = useContext(MeContext)
  const navigate = useNavigate()
  const { register, handleSubmit } = useForm()
  const membershipId = params.membershipId

  const MEMBERSHIP_FORM_MUTATION = gql`
    mutation MembershipFormMutation(
      $membershipId: ID!
      $memberRole: Int!
      $endDate: String
      $startDate: String!
      $hoursPerMonth: Int!
    ) {
      saveMembership(
        membershipId: $membershipId
        memberRole: $memberRole
        endDate: $endDate
        startDate: $startDate
        hoursPerMonth: $hoursPerMonth
      ) {
        membership {
          id
        }
      }
    }
  `

  const { data, loading } = useQuery<MembershipFormDTO>(MEMBERSHIP_FORM_QUERY, {
    variables: {
      membershipId,
    },
  })

  const membership = data?.membership
  const team = membership?.team
  const teamId = team?.id
  const company = me?.currentCompany
  const companyUrl = `/companies/${company?.slug}`
  const membershipsTableUrl = `${companyUrl}/teams/${teamId}/memberships`
  const breadcrumbsLinks = [
    { name: company?.name || "", url: companyUrl || "" },
    { name: team?.name || "", url: `${companyUrl}/teams/${teamId}` },
    { name: t("form.membershipsTable"), url: membershipsTableUrl },
    { name: membership?.teamMemberName || "", url: "" },
  ]

  const [saveMembership, { loading: mutationLoading }] =
    useMutation<MembershipFormDTO>(MEMBERSHIP_FORM_MUTATION, {
      update: () => navigate(membershipsTableUrl),
      refetchQueries: [{ query: MEMBERSHIP_TABLE_QUERY }],
    })

  const handleMembershipSubmit = (data: FieldValues) =>
    saveMembership({
      variables: {
        memberRole: Number(data.memberRole),
        hoursPerMonth: Number(data.hoursPerMonth),
        startDate: data.startDate,
        endDate: data.endDate || "",
        membershipId: membershipId,
      },
    })

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading || mutationLoading}
    >
      <Box sx={{ maxWidth: "480px", marginX: "auto", paddingY: 4 }}>
        <form onSubmit={handleSubmit(handleMembershipSubmit)}>
          <FormGroup>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="startDate" shrink>
                {t("form.startDate")}
              </InputLabel>
              <Input
                {...register("startDate", { required: true })}
                type="date"
                defaultValue={membership?.startDate}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="endDate" shrink>
                {t("form.endDate")}
              </InputLabel>
              <Input
                {...register("endDate")}
                type="date"
                defaultValue={membership?.endDate}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel htmlFor="hoursPerMonth">
                {t("form.hoursPerMonth")}
              </InputLabel>

              <Input
                defaultValue={membership?.hoursPerMonth}
                type="number"
                {...register("hoursPerMonth", { required: true })}
              />
            </FormControl>
            <FormControl sx={{ marginBottom: 4 }}>
              <InputLabel
                shrink
                sx={{ backgroundColor: "white" }}
                htmlFor="memberRole"
              >
                {t("form.memberRole")}
              </InputLabel>
              <Select
                native
                {...register("memberRole")}
                defaultValue={membership?.memberRole}
              >
                <option value="0">
                  {t("form.options.memberRole.developer")}
                </option>
                <option value="1">
                  {t("form.options.memberRole.manager")}
                </option>
                <option value="2">{t("form.options.memberRole.client")}</option>
                <option value="3">
                  {t("form.options.memberRole.designer")}
                </option>
              </Select>
            </FormControl>
            <Box sx={{ display: "flex", justifyContent: "flex-start" }}>
              <Button type="submit" variant="contained" sx={{ marginRight: 2 }}>
                {t("form.save")}
              </Button>
              <Button
                variant="outlined"
                component={Link}
                to={membershipsTableUrl}
              >
                {t("form.cancel")}
              </Button>
            </Box>
          </FormGroup>
        </form>
      </Box>
    </BasicPage>
  )
}

const MEMBERSHIP_FORM_QUERY = gql`
  query MembershipForm($membershipId: ID!) {
    membership(id: $membershipId) {
      id
      teamMemberName
      memberRole
      startDate
      endDate
      hoursPerMonth
      team {
        id
        name
      }
    }
  }
`

type MembershipFormDTO = {
  membership?: Membership
}

export default MembershipForm
