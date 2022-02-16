import { Fragment, useContext } from "react"
import { Backdrop, CircularProgress, Box, Typography } from "@mui/material"
import { gql, useQuery, useMutation } from "@apollo/client"
import CachedIcon from "@mui/icons-material/Cached"
import { useParams } from "react-router-dom"
import { format } from "date-fns"

import ReplenishingTeamInfo, {
  TeamReplenishment,
} from "../components/ReplenishingTeamInfo"
import ReplenishingProjectsInfo, {
  Project,
} from "../components/ReplenishingProjectsInfo"
import BasicPage, { MessagesContext } from "../components/BasicPage"
import { Company } from "../modules/company/company.types"

export const QUERY = gql`
  query Replenishing($teamId: Int!) {
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

type ReplenishingConsolidation = {
  id: string
  consolidationDate: string
  createdAt: string
  project: Project
  customerHappiness: number
}

export type Team = {
  id: string
  name: string
  company: Company
  increasedLeadtime80: boolean
  throughputData: number[]
  averageThroughput: number
  increasedAvgThroughtput: boolean
  leadTime: number
  workInProgress: number
  lastReplenishingConsolidations: ReplenishingConsolidation[]
}

type ReplenishingResult = {
  team: Team
}

type ReplenishingDTO = ReplenishingResult | undefined

type ReplenishingCacheResult = {
  generateReplenishingCache: {
    statusMessage: string
  }
}

type ReplenishingCacheDTO = ReplenishingCacheResult | undefined

const Replenishing = () => {
  const { teamId, companyNickName = "" } = useParams()
  const { data, loading, error } = useQuery<ReplenishingDTO>(QUERY, {
    variables: { teamId: Number(teamId) },
  })
  const { pushMessage } = useContext(MessagesContext)

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

  const company = data?.team.company
  const companyName = company.name
  const companyUrl = `/companies/${company.slug}`
  const teamName = data?.team.name
  const teamUrl = `/companies/${company.slug}/teams/${data?.team.id}`

  const breadcrumbsLinks = [
    { name: companyName || "", url: companyUrl },
    { name: teamName || "", url: teamUrl },
    { name: "Reabastecimento" },
  ]

  return (
    <BasicPage
      title="Reabastecimento"
      breadcrumbsLinks={breadcrumbsLinks}
      company={company}
    >
      {data?.team && (
        <Fragment>
          <Box
            display="flex"
            justifyContent="space-between"
            alignItems="center"
          >
            <Typography ml="auto" mr={1} variant="subtitle2">
              Última atualização em{" "}
              {format(
                new Date(data.team.lastReplenishingConsolidations[0].createdAt),
                "d/m/y"
              )}{" "}
              às{" "}
              {format(
                new Date(data.team.lastReplenishingConsolidations[0].createdAt),
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
          <ReplenishingTeamInfo team={normalizeTeamInfo(data)} />
          <ReplenishingProjectsInfo
            projects={normalizeProjectInfo(data)}
            companySlug={companyNickName}
          />
        </Fragment>
      )}
    </BasicPage>
  )
}

export default Replenishing

export const getProjects = (team: Team): Project[] =>
  team.lastReplenishingConsolidations.map(
    (consolidation) => consolidation.project
  )

export const normalizeTeamInfo = (
  data: ReplenishingDTO
): TeamReplenishment => ({
  throughputData: data?.team.throughputData,
  averageThroughput: data?.team && {
    value: data?.team.averageThroughput,
    increased: data?.team.increasedAvgThroughtput,
  },
  leadTime: data?.team && {
    value: data?.team.leadTime,
    increased: data?.team.increasedLeadtime80,
  },
  workInProgress: data?.team.workInProgress,
  projects: data ? getProjects(data.team) : [],
})

export const normalizeProjectInfo = (data: ReplenishingDTO): Project[] =>
  data
    ? data.team.lastReplenishingConsolidations.map(function (
        consolidation: ReplenishingConsolidation
      ) {
        return {
          ...consolidation.project,
          customerHappiness: consolidation.customerHappiness,
        }
      })
    : []
