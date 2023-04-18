import { Fragment, useContext } from "react"
import { Box, Typography } from "@mui/material"
import { gql, useQuery, useMutation } from "@apollo/client"
import CachedIcon from "@mui/icons-material/Cached"
import { useParams } from "react-router-dom"

import ReplenishingTeamInfo, {
  TeamReplenishment,
} from "../../components/ReplenishingTeamInfo"
import ReplenishingProjectsInfo from "../../components/ReplenishingProjectsInfo"
import { MessagesContext } from "../../contexts/MessageContext"
import { Team } from "../../modules/team/team.types"
import { Project } from "../../modules/project/project.types"
import { ReplenishingConsolidation } from "../../modules/replenishing/replenishingConsolidation.types"
import { formatDate } from "../../lib/date"
import TeamBasicPage from "../../modules/team/components/TeamBasicPage"

export const QUERY = gql`
  query Replenishing($teamId: ID!) {
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
          maxWorkInProgress
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

type ReplenishingResult = {
  team: Team
}

export type ReplenishingDTO = ReplenishingResult | undefined

type ReplenishingCacheResult = {
  generateReplenishingCache: {
    statusMessage: string
  }
}

type ReplenishingCacheDTO = ReplenishingCacheResult | undefined

const Replenishing = () => {
  const { teamId, companySlug = "" } = useParams()
  const { data, loading } = useQuery<ReplenishingDTO>(QUERY, {
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

  const company = data?.team.company
  const companyName = company?.name
  const companyUrl = `/companies/${company?.slug}`
  const teamName = data?.team.name
  const teamUrl = `/companies/${company?.slug}/teams/${data?.team.id}`
  const lastReplenishingConsolidations =
    data?.team.lastReplenishingConsolidations
  const hasReplenishing =
    Array.isArray(lastReplenishingConsolidations) &&
    lastReplenishingConsolidations.length
  const breadcrumbsLinks = [
    { name: companyName || "", url: companyUrl },
    { name: teamName || "", url: teamUrl },
    { name: "Reabastecimento" },
  ]
  return (
    <TeamBasicPage
      title="Reabastecimento"
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
    >
      {data?.team && (
        <Fragment>
          <Box
            display="flex"
            justifyContent="space-between"
            alignItems="center"
            mb={2}
          >
            <Typography ml="auto" mr={1} variant="subtitle2">
              {hasReplenishing
                ? `Última atualização em
              ${formatDate({
                date:
                  data.team.lastReplenishingConsolidations?.[0].createdAt || "",
                format: "dd/MM/yyyy' às 'HH:mm",
              })}`
                : "Sem dados suficientes para atualizar"}
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
            companySlug={companySlug}
          />
        </Fragment>
      )}
    </TeamBasicPage>
  )
}

export default Replenishing

export const getProjects = (team: Team): Project[] =>
  team.lastReplenishingConsolidations?.map(
    (consolidation) => consolidation.project
  ) || []

export const normalizeTeamInfo = (
  data: ReplenishingDTO
): TeamReplenishment => ({
  throughputData: data?.team.throughputData,
  averageThroughput: data?.team && {
    value: data?.team?.averageThroughput || 0,
    increased: data?.team?.increasedAvgThroughtput ?? false,
  },
  leadTime: data?.team && {
    value: data?.team?.leadTime ?? 0,
    increased: data?.team?.increasedLeadtime80 ?? false,
  },
  workInProgress: data?.team.workInProgress,
  projects: data ? getProjects(data.team) : [],
})

export const normalizeProjectInfo = (data: ReplenishingDTO): Project[] =>
  data?.team.lastReplenishingConsolidations?.map(function (
    consolidation: ReplenishingConsolidation
  ) {
    return {
      ...consolidation.project,
      customerHappiness: consolidation.customerHappiness,
    }
  }) || []
