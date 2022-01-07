// @ts-nocheck
import { normalizeProjectInfo, normalizeTeamInfo } from "../Replenishment"

describe("pages/Replenishment", () => {
  describe("valid data for team info from replenishing", () => {
    it("should normalize the team info into the query results to the component shape", () => {
      const expected = {
        throughputData: [9, 2, 4, 6],
        averageThroughput: {
          value: 5.25,
          increased: false,
        },
        leadTime: {
          value: 26.73062348611111,
          increased: true,
        },
        workInProgress: 13,
      }

      expect(normalizeTeamInfo(data)).toEqual(expected)
    })
  })

  describe("valid data for projects info from replenishing", () => {
    it("should normalize the team info into the query results to the component shape", () => {
      const expected = [
        {
          name: "Redesign - Informações de Venda",
          remainingWeeks: 2,
          remainingBacklog: 9,
          flowPressure: 2,
          flowPressurePercentage: 0,
          lastWeekThroughput: "3",
          leadTimeP80: 4366647.3092,
          qtySelected: 0,
          qtyInProgress: 1,
          monteCarloP80: 41,
          workInProgressLimit: 3,
          throughputsArray: "2, 3, 5, 3",
          qtyThroughputs: 10,
          modeWeeklyTroughputs: 3,
          stdDevWeeklyTroughputs: 2.1,
          teamMonteCarloP80: 5,
          teamMonteCarloWeeksMax: 1,
          teamMonteCarloWeeksMin: 10,
          teamMonteCarloWeeksStdDev: 4.5,
          teamBasedOddsToDeadline: 0.9,
        },
        {
          name: "Daily Bugle - Matéria Fofoca e Editorias Políticas",
          remainingWeeks: 5,
          remainingBacklog: 7,
          flowPressure: 0.25,
          flowPressurePercentage: 0,
          leadTimeP80: 0,
          qtySelected: 0,
          qtyInProgress: 0,
          monteCarloP80: 0,
          modeWeeklyTroughputs: 3,
          lastWeekThroughput: "3",
          workInProgressLimit: 3,
          throughputsArray: "2, 3, 5, 3",
          qtyThroughputs: 10,
          stdDevWeeklyTroughputs: 2.1,
          teamMonteCarloP80: 5,
          teamMonteCarloWeeksMax: 1,
          teamMonteCarloWeeksMin: 10,
          teamMonteCarloWeeksStdDev: 4.5,
          teamBasedOddsToDeadline: 0.9,
        },
      ]

      expect(normalizeProjectInfo(data)).toEqual(expected)
    })
  })
})

const data = {
  team: {
    id: "1",
    name: "Vingadores",
    throughputData: [9, 2, 4, 6],
    averageThroughput: 5.25,
    increasedAvgThroughtput: false,
    leadTime: 26.73062348611111,
    increasedLeadtime80: true,
    workInProgress: 13,
    lastReplenishingConsolidations: [
      {
        __typename: "ReplenishingConsolidation",
        id: "28231",
        project: {
          __typename: "Project",
          id: "673",
          name: "Redesign - Informações de Venda",
          remainingWeeks: 2,
          remainingBacklog: 9,
          flowPressure: 2,
          flowPressurePercentage: 0,
          leadTimeP80: 4366647.3092,
          qtySelected: 0,
          qtyInProgress: 1,
          monteCarloP80: 41,
          workInProgressLimit: 3,
          weeklyThroughputs: "2, 3, 5, 3",
          modeWeeklyTroughputs: 3,
          stdDevWeeklyTroughputs: 2.1,
          teamMonteCarloP80: 5,
          teamMonteCarloWeeksMax: 1,
          teamMonteCarloWeeksMin: 10,
          teamMonteCarloWeeksStdDev: 4.5,
          teamBasedOddsToDeadline: 0.9,
        },
      },
      {
        __typename: "ReplenishingConsolidation",
        id: "28232",
        project: {
          __typename: "Project",
          id: "689",
          name: "Daily Bugle - Matéria Fofoca e Editorias Políticas",
          remainingWeeks: 5,
          remainingBacklog: 7,
          flowPressure: 0.25,
          flowPressurePercentage: 0,
          leadTimeP80: 0,
          qtySelected: 0,
          qtyInProgress: 0,
          monteCarloP80: 0,
          modeWeeklyTroughputs: 3,
          workInProgressLimit: 3,
          weeklyThroughputs: "2, 3, 5, 3",
          stdDevWeeklyTroughputs: 2.1,
          teamMonteCarloP80: 5,
          teamMonteCarloWeeksMax: 1,
          teamMonteCarloWeeksMin: 10,
          teamMonteCarloWeeksStdDev: 4.5,
          teamBasedOddsToDeadline: 0.9,
        },
      },
    ],
  },
}
