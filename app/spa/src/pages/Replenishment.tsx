import { Fragment } from "react"
import {Container} from "@mui/material"
import { gql, useQuery } from "@apollo/client"

import ReplenishmentTeamInfo from "../components/ReplenishmentTeamInfo"
import ReplenishingProjectsInfo from "../components/ReplenishmentProjectsInfo"
import Header from '../components/Header'
import { useParams } from "react-router-dom"
import BreadcrumbReplenishingInfo from "../components/BreadcrumbReplenishingInfo";

const QUERY = gql`
  query Replenishment($teamId: Int!) {
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
        }
      }
    }
  }
`

const Replenishment = () => {
  const { teamId, companyNickName } = useParams()
  // const { data, loading, error } = useQuery(QUERY, {
  //   variables: { teamId: Number(teamId) },
  // })

  // if (error) {
  //   console.error(error)
  // }

  // if (loading) return <Container>"carregando..."</Container>

  const mockedData = {
    "team": {
        "id": "1",
        "name": "Vingadores",
        company: {
          name: "ACME Inc",
          nickName: "acme"
        },
        "throughputData": [
            9,
            2,
            4,
            6
        ],
        "averageThroughput": 5.25,
        "increasedAvgThroughtput": false,
        "leadTime": 26.73062348611111,
        "increasedLeadtime80": true,
        "workInProgress": 13,
        "lastReplenishingConsolidations": [
            {
                "__typename": "ReplenishingConsolidation",
                "id": "28231",
                "project": {
                    "__typename": "Project",
                    "id": "673",
                    "name": "Redesign - Informações de Venda",
                    "remainingWeeks": 2,
                    "remainingBacklog": 9,
                    "flowPressure": 2,
                    "flowPressurePercentage": 0,
                    "leadTimeP80": 4366647.3092,
                    "qtySelected": 0,
                    "qtyInProgress": 1,
                    "monteCarloP80": 41
                }
            },
            {
                "__typename": "ReplenishingConsolidation",
                "id": "28232",
                "project": {
                    "__typename": "Project",
                    "id": "689",
                    "name": "Daily Bugle - Matéria Fofoca e Editorias Políticas",
                    "remainingWeeks": 5,
                    "remainingBacklog": 7,
                    "flowPressure": 0.25,
                    "flowPressurePercentage": 0,
                    "leadTimeP80": 0,
                    "qtySelected": 0,
                    "qtyInProgress": 0,
                    "monteCarloP80": 0
                }
            }
        ]
    }
}


  return (
      <Fragment>
        <Header companyName={mockedData.team.company.nickName} />
      <Container>
        {mockedData?.team && (
            <Fragment>
              <BreadcrumbReplenishingInfo replenishingBreadcrumb={normalizeBreadcrumbReplenishing(companyNickName!, teamId!, mockedData)} />
              <ReplenishmentTeamInfo team={normalizeTeamInfo(mockedData)} />
              <ReplenishingProjectsInfo projects={normalizeProjectInfo(mockedData)} />
            </Fragment>
        )}
      </Container>
      </Fragment>
  )
}

export default Replenishment

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

export const normalizeBreadcrumbReplenishing = (companyNickName: String, teamId: String, data: any) => {
  const teamUrl = `/companies/${ companyNickName }/teams/${ teamId }`
  const companyUrl = `/companies/${ companyNickName }/`
  return {
    companyName: data.team.company.name,
    companyUrl: companyUrl,
    teamName: data.team.name,
    teamUrl: teamUrl
  }
}

export const normalizeProjectInfo = (data: any) => (
    data.team.lastReplenishingConsolidations.map(function (consolidation: any) {
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
      }
    })
)
