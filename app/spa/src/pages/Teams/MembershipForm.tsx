import BasicPage from "../../components/BasicPage"
import { useParams } from "react-router-dom"
import { gql } from "@apollo/client"
import { format, subWeeks } from "date-fns"
import { Membership, Team } from "../../modules/team/team.types"

const MembershipForm = () => {
  const params = useParams()
  const teamId = params.teamId || ""
  const membershipId = params.membershipId || ""

  const breadcrumbsLinks = [
    { name: company?.name || "", url: companyUrl || "" },
    { name: team?.name || "", url: `${companyUrl}/teams/${teamId}` },
    { name: t("list.title") },
  ]

  return <BasicPage breadcrumbsLinks={breadcrumbsLinks}></BasicPage>
}

const TEAM_DASHBOARD_QUERY = gql`
  query TeamDashboard($teamId: Int!, $startDate: ISO8601Date, $endDate: ISO8601Date) {
    team(id: $teamId) {
      id
      name
      startDate
      endDate
      leadTimeP65
      leadTimeP80
      leadTimeP95
      numberOfDemandsDelivered
      activeBillableCount
      cumulativeFlowChartData(startDate: $startDate, endDate: $endDate) {
        xAxis
        yAxis {
          name
          data
        }
      }
      demandsFlowChartData(startDate: $startDate, endDate: $endDate) {
        creationChartData
        committedChartData
        pullTransactionRate
        throughputChartData
        xAxis
      }
      leadTimeHistogramData(startDate: $startDate, endDate: $endDate) {
        keys
        values
      }
      biggestFiveLeadTimes: latestDeliveries(orderField: "leadtime", sortDirection: DESC, limit: 5) {
        ...demand
      }
      biggestFiveLeadTimesInFourWeeks: latestDeliveries(
        orderField: "leadtime"
        sortDirection: DESC
        limit: 5
        startDate: "${format(subWeeks(new Date(), 4), "yyyy-MM-dd")}"
      ) {
        ...demand
      }
      teamConsolidationsWeekly(startDate: $startDate, endDate: $endDate) {
        leadTimeP80
        consolidationDate
      }
      teamMonthlyInvestment(startDate: $startDate, endDate: $endDate) {
        xAxis
        yAxis
      }
    }
  }

  fragment demand on Demand {
    id
    leadtime
    endDate
    product {
      id
      name
    }
    project {
      id
      name
    }
  }
`

type MembershipFormDTO = {
  membership: Membership
}

export default MembershipForm
