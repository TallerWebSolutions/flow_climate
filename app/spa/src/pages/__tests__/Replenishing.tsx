import { render, within } from "@testing-library/react"
import { MockedProvider } from "@apollo/client/testing"

import ReplenishingPage, {
  normalizeProjectInfo,
  normalizeTeamInfo,
  getProjects,
  QUERY as REPLENISHING_QUERY,
} from "../Replenishing"

import {
  teamMock,
  projectMock,
  companyMock,
  replenishingMock as data,
} from "../../lib/mocks"
import { MemoryRouter, Route, Routes } from "react-router-dom"

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
        projects: [projectMock],
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

  describe("breadcrumbs", () => {
    it("should render breadcrumb from query data", async () => {
      const mocks = [
        {
          request: {
            query: REPLENISHING_QUERY,
            variables: {
              teamId: 1,
            },
          },
          result: { data },
        },
      ]

      const page = render(
        <MockedProvider mocks={mocks} addTypename={false}>
          <MemoryRouter
            initialEntries={[
              "/companies/taller/teams/1/replenishing_consolidations",
            ]}
          >
            <Routes>
              <Route
                path="/companies/:companyNickName/teams/:teamId/replenishing_consolidations"
                element={<ReplenishingPage />}
              />
            </Routes>
          </MemoryRouter>
        </MockedProvider>
      )

      await new Promise((resolve) => setTimeout(resolve, 0))

      const breadcrumbs = await page.findByTestId("breadcrumbs")
      const companyLink = within(breadcrumbs).getAllByText("Taller")
      const teamLink = within(breadcrumbs).queryAllByText("Vingadores")

      expect(companyLink).toHaveLength(1)
      expect(companyLink[0]).toHaveAttribute("href", "/companies/taller")

      expect(teamLink).toHaveLength(1)
      expect(teamLink[0]).toHaveAttribute("href", "/companies/taller/teams/1")
    })
  })
})
