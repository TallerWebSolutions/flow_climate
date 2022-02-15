import { MockedProvider } from "@apollo/client/testing"
import { render, within } from "@testing-library/react"
import { MemoryRouter, Route, Routes } from "react-router-dom"
import { projectMock } from "../../lib/mocks"

import StatusReportPage, { QUERY as STATUS_REPORT_QUERY } from "../StatusReport"

describe("pages/StatusReport", () => {
  describe("breadcrumbs", () => {
    it("should render breadcrumb from query data", async () => {
      const mocks = [
        {
          request: {
            query: STATUS_REPORT_QUERY,
            variables: {
              id: 1,
            },
          },
          result: {
            data: {
              project: projectMock,
            },
          },
        },
      ]

      const page = render(
        <MockedProvider mocks={mocks} addTypename={false}>
          <MemoryRouter
            initialEntries={[
              "/companies/taller/projects/1/status_report_dashboard",
            ]}
          >
            <Routes>
              <Route
                path="/companies/taller/projects/:projectId/status_report_dashboard"
                element={<StatusReportPage />}
              />
            </Routes>
          </MemoryRouter>
        </MockedProvider>
      )

      await new Promise((resolve) => setTimeout(resolve, 0))

      const breadcrumbs = await page.findByTestId("breadcrumbs")
      const companyLink = within(breadcrumbs).getAllByText("Taller")
      expect(companyLink).toHaveLength(1)
      expect(companyLink[0]).toHaveAttribute("href", "/companies/taller")

      const projectLink = within(breadcrumbs).queryAllByText("Project X")
      expect(projectLink[0]).toBeTruthy()
      expect(projectLink[0]).toHaveAttribute(
        "href",
        "/companies/taller/projects/1"
      )
    })
  })
})
