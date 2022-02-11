import { MockedProvider } from "@apollo/client/testing"
import { render, within } from "@testing-library/react"

import StatusReportPage from '../StatusReport'

describe("pages/StatusReport", () => {
  describe("breadcrumbs", () => {
    it("should render breadcrumb from query data", async () => {
      const page = render(
        <MockedProvider>
          <StatusReportPage />
        </MockedProvider>
      )

      await new Promise((resolve) => setTimeout(resolve, 0))

      const breadcrumbs = await page.findByTestId("breadcrumbs")
      const companyLink = within(breadcrumbs).getAllByText("Taller")
      expect(companyLink).toHaveLength(1)
      expect(companyLink[0]).toHaveAttribute("href", "/companies/taller")

      // Home TALLER Projetos IstoÉ CMS
    })
  })
})
