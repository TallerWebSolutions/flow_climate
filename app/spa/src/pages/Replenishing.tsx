import { Fragment } from "react"
import { Backdrop, CircularProgress, Container } from "@mui/material"
import { gql, useQuery } from "@apollo/client"

import ReplenishingTeamInfo from "../components/ReplenishingTeamInfo"
import ReplenishingProjectsInfo from "../components/ReplenishingProjectsInfo"
import Header, { User as HeaderUser } from "../components/Header"
import { useParams } from "react-router-dom"
import BreadcrumbReplenishingInfo from "../components/BreadcrumbReplenishingInfo"

const QUERY = gql`
  query Replenishing($teamId: Int!) {
    me {
      id
      fullName
      avatar {
        imageSource
      }
    }
    team(id: $teamId) {
      id
      name
      throughputData
      averageThroughput
      increasedAvgThroughtput
      leadTime
      increasedLeadtime80
      workInProgress
      company {
        id
        name
        slug
      }
      lastReplenishingConsolidations(
        orderBy: "consolidation_date"
        direction: "asc"
        limit: 1
      ) {
        id
        project {
          id
          name
          remainingWeeks
          remainingBacklog
          flowPressure
          flowPressurePercentage
          leadTimeP80
          qtySelected
          qtyInProgress
          monteCarloP80
          workInProgressLimit
          weeklyThroughputs
          modeWeeklyTroughputs
          stdDevWeeklyTroughputs
          teamMonteCarloP80
          teamMonteCarloWeeksMax
          teamMonteCarloWeeksMin
          teamMonteCarloWeeksStdDev
          teamBasedOddsToDeadline
        }
      }
    }
  }
`

type Company = {
  id: string
  name: string
  slug: string
}

type Team = {
  id: string
  company: Company
}

type User = {
  id: string
  fullName: string
  avatar: {
    imageSource: string
  }
}

type ReplenishingDTO = {
  team: Team
  me: User
}

const Replenishing = () => {
  const { teamId, companyNickName } = useParams()
  const { data, loading, error } = useQuery<ReplenishingDTO>(QUERY, {
    variables: { teamId: Number(teamId) },
  })

  if (error) {
    console.error(error)
  }

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <Fragment>
      <Header company={data?.team.company} user={normalizeUser(data)} />
      <Container>
        {data?.team && (
          <Fragment>
            <BreadcrumbReplenishingInfo
              replenishingBreadcrumb={normalizeBreadcrumbReplenishing(
                companyNickName!,
                teamId!,
                data
              )}
            />
            <ReplenishingTeamInfo team={normalizeTeamInfo(data)} />
            <ReplenishingProjectsInfo projects={normalizeProjectInfo(data)} />
          </Fragment>
        )}
      </Container>
    </Fragment>
  )
}

export default Replenishing

export const normalizeTeamInfo = (data: any) => ({
  throughputData: data.team.throughputData,
  averageThroughput: {
    value: data.team.averageThroughput,
    increased: data.team.increasedAvgThroughtput,
  },
  leadTime: {
    value: data.team.leadTime,
    increased: data.team.increasedLeadtime80,
  },
  workInProgress: data.team.workInProgress,
})

const normalizeBreadcrumbReplenishing = (
  companyNickName: String,
  teamId: String,
  data: any
) => {
  const teamUrl = `/companies/${companyNickName}/teams/${teamId}`
  const companyUrl = `/companies/${companyNickName}/`
  return {
    companyName: data.team.company.name,
    companyUrl: companyUrl,
    teamName: data.team.name,
    teamUrl: teamUrl,
  }
}

export const normalizeProjectInfo = (data: any) =>
  data.team.lastReplenishingConsolidations.map(function (consolidation: any) {
    const weeklyThroughputs = consolidation.project.weeklyThroughputs
    const throughputsSize = weeklyThroughputs.length

    return {
      name: consolidation.project.name,
      remainingWeeks: consolidation.project.remainingWeeks,
      remainingBacklog: consolidation.project.remainingBacklog,
      flowPressure: consolidation.project.flowPressure,
      flowPressurePercentage: consolidation.project.flowPressurePercentage,
      leadTimeP80: consolidation.project.leadTimeP80,
      qtySelected: consolidation.project.qtySelected,
      qtyInProgress: consolidation.project.qtyInProgress,
      monteCarloP80: consolidation.project.monteCarloP80,
      workInProgressLimit: consolidation.project.workInProgressLimit,
      lastWeekThroughput: weeklyThroughputs[throughputsSize - 1],
      qtyThroughputs: throughputsSize,
      throughputsArray: weeklyThroughputs,
      modeWeeklyTroughputs: consolidation.project.modeWeeklyTroughputs,
      stdDevWeeklyTroughputs: consolidation.project.stdDevWeeklyTroughputs,
      teamMonteCarloP80: consolidation.project.teamMonteCarloP80,
      teamMonteCarloWeeksMin: consolidation.project.teamMonteCarloWeeksMin,
      teamMonteCarloWeeksMax: consolidation.project.teamMonteCarloWeeksMax,
      teamMonteCarloWeeksStdDev:
        consolidation.project.teamMonteCarloWeeksStdDev,
      teamBasedOddsToDeadline: consolidation.project.teamBasedOddsToDeadline,
    }
  })

const normalizeUser = (data: ReplenishingDTO | undefined): HeaderUser => ({
  id: data?.me.id || "",
  fullName: data?.me.fullName || "",
  avatarSource: data?.me.avatar.imageSource || "",
})

export const toImplementMessage = () => alert("trabalho em progresso...")