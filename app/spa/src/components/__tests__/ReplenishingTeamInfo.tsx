import { render } from "@testing-library/react"

import { projectMock } from "../../lib/mocks"

import ReplenishmentTeamInfo, {
  getWipLimits,
  isTeamWipLimitSurpassed,
} from "../ReplenishingTeamInfo"

describe("components/ReplenishmentTeamInfo", () => {
  it("should render", () => {
    const team = {
      throughputData: [1, 2, 3, 4],
      averageThroughput: {
        value: 2.5,
        increased: true,
      },
      leadTime: {
        value: 20,
        increased: true,
      },
      workInProgress: 3,
    }

    render(<ReplenishmentTeamInfo team={team} />)
  })

  it("should render even with missing values", () => {
    const team1 = {
      throughputData: [],
      averageThroughput: {
        value: 2.5,
        increased: true,
      },
      leadTime: {
        value: 20,
        increased: true,
      },
      workInProgress: 3,
    }

    const team2 = {
      averageThroughput: {
        value: 2.5,
        increased: true,
      },
      leadTime: {
        value: 20,
        increased: true,
      },
      workInProgress: 3,
    }

    const team3 = {
      leadTime: {
        value: 20,
        increased: true,
      },
      workInProgress: 3,
    }

    const team4 = {
      workInProgress: 3,
    }

    const team5 = {}

    render(<ReplenishmentTeamInfo team={team1} />)
    render(<ReplenishmentTeamInfo team={team2} />)
    render(<ReplenishmentTeamInfo team={team3} />)
    render(<ReplenishmentTeamInfo team={team4} />)
    render(<ReplenishmentTeamInfo team={team5} />)
  })
})

describe("normalizers/ReplenishmentTeamInfo", () => {
  it("should get wip limit from all projects", () => {
    expect(getWipLimits([])).toEqual([])
    expect(getWipLimits([projectMock])).toEqual([23])
    expect(getWipLimits([projectMock, projectMock])).toEqual([23, 23])
  })

  it("should tell if team wip limit is surpassed", () => {
    expect(isTeamWipLimitSurpassed([projectMock], 1)).toEqual(true)
    expect(isTeamWipLimitSurpassed([projectMock], 24)).toEqual(false)
    expect(isTeamWipLimitSurpassed([projectMock], 23)).toEqual(false)
  })
})
