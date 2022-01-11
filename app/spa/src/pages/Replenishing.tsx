import { Fragment, useState } from "react"
import { Backdrop, CircularProgress, Container, Box } from "@mui/material"
import { gql, useQuery, useMutation } from "@apollo/client"
import CachedIcon from "@mui/icons-material/Cached"

import ReplenishingTeamInfo from "../components/ReplenishingTeamInfo"
import ReplenishingProjectsInfo from "../components/ReplenishingProjectsInfo"
import Header, { User as HeaderUser } from "../components/Header"
import { useParams } from "react-router-dom"
import BreadcrumbReplenishingInfo from "../components/BreadcrumbReplenishingInfo"
import MessagesBox from "../components/MessagesBox"

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
        consolidationDate
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

const GENERATE_REPLENISHING_MUTATION = gql`
  mutation GenerateReplenishingCache($teamId: String!) {
    generateReplenishingCache(teamId: $teamId) {
      statusMessage
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

type ReplenishingDTO =
  | {
      team: Team
      me: User
    }
  | undefined

const Replenishing = () => {
  const { teamId, companyNickName } = useParams()
  const { data, loading, error } = useQuery<ReplenishingDTO>(QUERY, {
    variables: { teamId: Number(teamId) },
  })

  const [generateReplenishingCache, { data: generateReplenishingCacheData }] =
    useMutation(GENERATE_REPLENISHING_MUTATION)

  const [messages, setMessages] = useState([])

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
            <Box
              display="flex"
              justifyContent="space-between"
              alignItems="center"
            >
              <BreadcrumbReplenishingInfo
                replenishingBreadcrumb={normalizeBreadcrumbReplenishing(
                  data,
                  companyNickName,
                  teamId
                )}
              />
              <CachedIcon
                onClick={() =>
                  generateReplenishingCache({
                    variables: { teamId: data.team.id },
                  })
                }
              />
            </Box>
            <ReplenishingTeamInfo team={normalizeTeamInfo(data)} />
            <ReplenishingProjectsInfo projects={normalizeProjectInfo(data)} />
          </Fragment>
        )}
        <MessagesBox messages={messages} />
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
  data: any,
  companyNickName?: string,
  teamId?: string
) => {
  const teamUrl = `/companies/${companyNickName}/teams/${teamId}`
  const companyUrl = `/companies/${companyNickName}/`
  return {
    companyName: data.team.company.name,
    companyUrl,
    teamName: data.team.name,
    teamUrl,
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

const normalizeUser = (data: ReplenishingDTO): HeaderUser => ({
  id: data?.me.id || "",
  fullName: data?.me.fullName || "",
  avatarSource: data?.me.avatar.imageSource || "",
})
