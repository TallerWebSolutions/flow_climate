import { MockedProvider } from "@apollo/client/testing"
import { render, within } from "@testing-library/react"
import { I18nextProvider } from "react-i18next"
import { MemoryRouter, Route, Routes } from "react-router-dom"
import i18n from "../../lib/i18n"
import { projectMock } from "../../lib/mocks"
import StatusReportPage, {
  QUERY as STATUS_REPORT_QUERY,
} from "../Projects/StatusReport"

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

const PageComponent = () => (
  <I18nextProvider i18n={i18n}>
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
  </I18nextProvider>
)

// @see: https://github.com/plouc/nivo/issues/1928
describe.skip("pages/StatusReport", () => {
  describe("breadcrumbs", () => {
    it("should render breadcrumb from query data", async () => {
      const page = render(<PageComponent />)

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

  describe("main menu", () => {
    it("should render main menu items using company slug from query data", async () => {
      const page = render(<PageComponent />)

      await new Promise((resolve) => setTimeout(resolve, 0))

      const mainMenu = await page.findByTestId("main-menu")

      const companyMenuItem = within(mainMenu).queryAllByText("Taller")
      expect(companyMenuItem[0]).toHaveAttribute("href", "/companies/taller")

      const clientsMenuItem = within(mainMenu).queryAllByText("Clientes")
      expect(clientsMenuItem[0]).toHaveAttribute(
        "href",
        "/companies/taller/customers"
      )

      const productsMenuItem = within(mainMenu).queryAllByText("Produtos")
      expect(productsMenuItem[0]).toHaveAttribute(
        "href",
        "/companies/taller/products"
      )

      const initiativesMenuItem = within(mainMenu).queryAllByText("Iniciativas")
      expect(initiativesMenuItem[0]).toHaveAttribute(
        "href",
        "/companies/taller/initiatives"
      )

      const projectsMenuItem = within(mainMenu).queryAllByText("Projetos")
      expect(projectsMenuItem[0]).toHaveAttribute(
        "href",
        "/companies/taller/projects"
      )

      const demandsMenuItem = within(mainMenu).queryAllByText("Demandas")
      expect(demandsMenuItem[0]).toHaveAttribute(
        "href",
        "/companies/taller/demands"
      )

      const demandBlocksMenuItem = within(mainMenu).queryAllByText("Bloqueios")
      expect(demandBlocksMenuItem[0]).toHaveAttribute(
        "href",
        "/companies/taller/demand_blocks"
      )

      const flowEventsBlocksMenuItem =
        within(mainMenu).queryAllByText("Eventos")
      expect(flowEventsBlocksMenuItem[0]).toHaveAttribute(
        "href",
        "/companies/taller/flow_events"
      )
    })
  })
})
