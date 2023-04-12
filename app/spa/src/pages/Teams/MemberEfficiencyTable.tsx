import { useTranslation } from "react-i18next"
import { useParams, useSearchParams } from "react-router-dom"
import { gql, useQuery } from "@apollo/client"
import {
  Button,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Select,
} from "@mui/material"
import { useForm } from "react-hook-form"
import SearchIcon from "@mui/icons-material/Search"

import BasicPage from "../../components/BasicPage"
import { MembershipEfficiencyData, Team } from "../../modules/team/team.types"
import Table from "../../components/ui/Table"
import { FormElement } from "../../components/ui/Form"

const MemberEfficiencyTable = () => {
  const { t } = useTranslation("teamMembers")
  const { register } = useForm()
  const [searchParams] = useSearchParams()
  const { teamId, companySlug } = useParams()
  const currentMonth = new Date().getMonth() + 1
  const currentYear = new Date().getFullYear()
  const { data, loading } = useQuery<MembershipsEfficiencyTable>(
    MEMBER_EFFICIENCY_TABLE_QUERY,
    {
      variables: {
        teamId: Number(teamId),
        month: Number(searchParams.get("month") || currentMonth),
        year: Number(searchParams.get("year") || currentYear),
      },
    }
  )

  const team = data?.team

  const company = team?.company
  const companyUrl = `/companies/${companySlug}`

  const breadcrumbsLinks = [
    { name: company?.name || "", url: companyUrl || "" },
    { name: team?.name || "", url: `${companyUrl}/teams/${teamId}` },
    { name: t("list.title") },
  ]
  const valuePerMemberColumns = [
    " ",
    t("list.hours"),
    t("list.producedValue"),
    t("list.capacity"),
    t("list.avgHoursPerDemand"),
  ]

  const valuePerMemberRow = team?.teamMemberEfficiency?.membersEfficiency?.map(
    (membershipEfficency: MembershipEfficiencyData) => {
      return [
        membershipEfficency.membership?.teamMemberName,
        membershipEfficency.effortInMonth?.toFixed(2),
        membershipEfficency.realizedMoneyInMonth?.toLocaleString("pt-br", {
          style: "currency",
          currency: "BRL",
        }),
        membershipEfficency.memberCapacityValue,
        membershipEfficency.avgHoursPerDemand?.toFixed(2),
      ]
    }
  )

  return (
    <BasicPage
      title={t("list.title", { teamName: team?.name || "" })}
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
      {team && (
        <>
          <form>
            <FormGroup>
              <Grid container spacing={5} marginBottom={4}>
                <FormElement>
                  <InputLabel shrink htmlFor="month">
                    {t("list.search.month")}
                  </InputLabel>
                  <Select
                    native
                    {...register("month")}
                    defaultValue={searchParams?.get("month") || currentMonth}
                  >
                    <option value="1">{t("list.search.january")}</option>
                    <option value="2">{t("list.search.february")}</option>
                    <option value="3">{t("list.search.march")}</option>
                    <option value="4">{t("list.search.april")}</option>
                    <option value="5">{t("list.search.may")}</option>
                    <option value="6">{t("list.search.june")}</option>
                    <option value="7">{t("list.search.july")}</option>
                    <option value="8">{t("list.search.august")}</option>
                    <option value="9">{t("list.search.september")}</option>
                    <option value="10">{t("list.search.october")}</option>
                    <option value="11">{t("list.search.november")}</option>
                    <option value="12">{t("list.search.december")}</option>
                  </Select>
                </FormElement>
                <FormElement>
                  <InputLabel shrink htmlFor="year">
                    {t("list.search.year")}
                  </InputLabel>
                  <Input
                    {...register("year")}
                    type="number"
                    defaultValue={searchParams.get("year") || currentYear}
                  />
                </FormElement>
                <FormElement>
                  <Button sx={{ alignSelf: "flex-start" }} type="submit">
                    <SearchIcon fontSize="large" color="primary" />
                  </Button>
                </FormElement>
              </Grid>
            </FormGroup>
          </form>
          <Table
            title={`${t("list.averageHoursPerMember", {
              hours: team.teamMemberEfficiency?.avgHoursPerMember?.toFixed(2),
            })}`}
            headerCells={valuePerMemberColumns}
            rows={valuePerMemberRow!}
          />
        </>
      )}
    </BasicPage>
  )
}

type MembershipsEfficiencyTable = {
  team: Team
}

export const MEMBER_EFFICIENCY_TABLE_QUERY = gql`
  query MemberEfficiencyTable($teamId: ID!, $month: Int, $year: Int) {
    team(id: $teamId) {
      id
      name
      company {
        id
        name
      }
      teamMemberEfficiency(month: $month, year: $year) {
        avgHoursPerMember
        avgMoneyPerMember
        totalHoursProduced
        totalMoneyProduced
        teamCapacityHours
        membersEfficiency {
          membership {
            id
            teamMemberName
          }
          avgHoursPerDemand
          effortInMonth
          realizedMoneyInMonth
          memberCapacityValue
        }
      }
    }
  }
`

export default MemberEfficiencyTable
