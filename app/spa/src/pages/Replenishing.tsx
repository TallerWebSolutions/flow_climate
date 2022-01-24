import { Fragment, useEffect, useState } from "react"
import {
  Backdrop,
  CircularProgress,
  Container,
  Box,
  Typography,
} from "@mui/material"
import { gql, useQuery, useMutation } from "@apollo/client"
import CachedIcon from "@mui/icons-material/Cached"

import ReplenishingTeamInfo from "../components/ReplenishingTeamInfo"
import ReplenishingProjectsInfo from "../components/ReplenishingProjectsInfo"
import Header, { User as HeaderUser } from "../components/Header"
import { useParams } from "react-router-dom"
import BreadcrumbReplenishingInfo from "../components/BreadcrumbReplenishingInfo"
import MessagesBox, { Message } from "../components/MessagesBox"
import { format } from "date-fns"

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
      lastReplenishingConsolidations {
        id
        consolidationDate
        customerHappiness
        createdAt
        project {
          id
          name
          aging
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
          startDate
          endDate
          stdDevWeeklyTroughputs
          teamMonteCarloP80
          teamMonteCarloWeeksMax
          teamMonteCarloWeeksMin
          teamMonteCarloWeeksStdDev
          teamBasedOddsToDeadline
          customers {
            id
            name
          }
          products {
            id
            name
          }
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
  id: number
  name: string
  slug: string
}

type ReplenishingConsolidation = {
  id: string
  consolidationDate: string
  createdAt: string
}

type Team = {
  id: string
  company: Company
  lastReplenishingConsolidations: ReplenishingConsolidation[]
}

type User = {
  id: string
  fullName: string
  avatar: {
    imageSource: string
  }
}

type ReplenishingResult = {
  team: Team
  me: User
}

type ReplenishingDTO = ReplenishingResult | undefined

type ReplenishingCacheResult = {
  generateReplenishingCache: {
    statusMessage: string
  }
}

type ReplenishingCacheDTO = ReplenishingCacheResult | undefined

const useMessages = (): [Message[], (message: Message) => void] => {
  const [messages, setMessages] = useState<Message[]>([])

  const pushMessage = (message: Message) => {
    setMessages((messages) => [...messages, message])
  }

  return [messages, pushMessage]
}

const Replenishing = () => {
  const { teamId, companyNickName = "" } = useParams()
  const { data, loading, error } = useQuery<ReplenishingDTO>(QUERY, {
    variables: { teamId: Number(teamId) },
  })

  const [messages, pushMessage] = useMessages()

  const [generateReplenishingCache] = useMutation<ReplenishingCacheDTO>(
    GENERATE_REPLENISHING_MUTATION,
    {
      update: () =>
        pushMessage({
          text: "Sua solicitação foi colocada na fila. Em poucos minutos estará pronta.",
          severity: "info",
        }),
    }
  )

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
      <Header
        company={data?.team.company}
        user={normalizeUser(data)}
        pushMessage={pushMessage}
      />
      <Container maxWidth="xl">
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
              <Typography ml="auto" mr={1} variant="subtitle2">
                Última atualização em{" "}
                {format(
                  new Date(
                    data.team.lastReplenishingConsolidations[0].createdAt
                  ),
                  "d/m/y"
                )}{" "}
                às{" "}
                {format(
                  new Date(
                    data.team.lastReplenishingConsolidations[0].createdAt
                  ),
                  "h:mm"
                )}
              </Typography>
              <CachedIcon
                onClick={() =>
                  generateReplenishingCache({
                    variables: { teamId: data.team.id },
                  })
                }
                sx={{ cursor: "pointer" }}
              />
            </Box>
            <Typography component="h1" variant="h4" mb={3}>
              Reabastecimento
            </Typography>
            <ReplenishingTeamInfo team={normalizeTeamInfo(data)} />
            <ReplenishingProjectsInfo
              projects={normalizeProjectInfo(data)}
              companySlug={companyNickName}
            />
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
    return {
      ...consolidation.project,
      customerHappiness: consolidation.customerHappiness,
    }
  })

const normalizeUser = (data: ReplenishingDTO): HeaderUser => ({
  id: data?.me.id || "",
  fullName: data?.me.fullName || "",
  avatarSource: data?.me.avatar.imageSource || "",
})
