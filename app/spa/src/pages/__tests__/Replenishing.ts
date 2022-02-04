// @ts-nocheck
import {
  normalizeProjectInfo,
  normalizeTeamInfo,
  getProjects,
} from "../Replenishing"

import {
  teamMock,
  projectMock,
  replenishingMock as data,
} from "../../lib/mocks"

describe("pages/Replenishing", () => {
  describe("normalizers", () => {
    it("should get all projects from team data", () => {
      expect(getProjects(teamMock)).toEqual([projectMock])
    })
  })

  describe("valid data for team info from replenishing", () => {
    it("should normalize the team info into the query results to the component shape", () => {
      const expected = {
        averageThroughput: {
          increased: true,
          value: 3,
        },
        leadTime: {
          increased: false,
          value: 10,
        },
        projects: [
          {
            aging: 5,
            customerHappiness: 1,
            customers: [],
            endDate: "12/12/12",
            flowPressure: 12,
            flowPressurePercentage: 43,
            id: "1",
            lastWeekThroughput: 54,
            leadTimeP80: 32,
            modeWeeklyTroughputs: 3,
            monteCarloP80: 89,
            name: "Project X",
            products: [],
            qtyInProgress: 9,
            qtySelected: 8,
            remainingBacklog: 20,
            remainingWeeks: 10,
            startDate: "11/11/11",
            stdDevWeeklyTroughputs: 4,
            teamBasedOddsToDeadline: 4.9999999999,
            teamMonteCarloP80: 3,
            teamMonteCarloWeeksMax: 9,
            teamMonteCarloWeeksMin: 1,
            teamMonteCarloWeeksStdDev: 3,
            weeklyThroughputs: [0, 1, 2, 3, 4, 3],
            workInProgressLimit: 9,
          },
        ],
        throughputData: [1, 2, 3, 4, 5],
        workInProgress: 10,
      }

      expect(normalizeTeamInfo(data)).toEqual(expected)
    })
  })

  describe("valid data for projects info from replenishing", () => {
    it("should normalize the team info into the query results to the component shape", () => {
      const expected = [projectMock]

      expect(normalizeProjectInfo(data)).toEqual(expected)
    })
  })
})
