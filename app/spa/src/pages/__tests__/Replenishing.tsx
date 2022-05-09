import { MockedProvider } from "@apollo/client/testing"
import { render, RenderResult, within } from "@testing-library/react"
import { act } from "react-dom/test-utils"
import { I18nextProvider } from "react-i18next"
import { MemoryRouter, Route, Routes } from "react-router-dom"
import i18n from "../../lib/i18n"
import {
  projectMock,
  replenishingMock as data,
  teamMock,
} from "../../lib/mocks"
import ReplenishingPage, {
  getProjects,
  normalizeProjectInfo,
  normalizeTeamInfo,
  QUERY as REPLENISHING_QUERY,
} from "../Teams/Replenishing"

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

      let container: RenderResult
      act(() => {
        container = render(
          <I18nextProvider i18n={i18n}>
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
          </I18nextProvider>
        )
      })

      const breadcrumbs = await container.findByTestId("breadcrumbs")
      const companyLink = within(breadcrumbs).getAllByText("Taller")
      const teamLink = within(breadcrumbs).queryAllByText("Vingadores")

      expect(companyLink).toHaveLength(1)
      expect(companyLink[0]).toHaveAttribute("href", "/companies/taller")

      expect(teamLink).toHaveLength(1)
      expect(teamLink[0]).toHaveAttribute("href", "/companies/taller/teams/1")
    })
  })
})
