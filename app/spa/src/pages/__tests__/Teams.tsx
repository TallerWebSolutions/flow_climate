import Teams, { TEAMS_QUERY } from "../Teams"
import { render, within, waitForElement, waitFor } from "@testing-library/react"
import { MockedProvider } from "@apollo/client/testing"
import { MemoryRouter, Routes, Route } from "react-router-dom"
import { meMock, teamMock } from "../../lib/mocks"
import { I18nextProvider } from "react-i18next"
import i18n from "../../lib/i18n"

const mocks = [
  {
    request: {
      query: TEAMS_QUERY,
    },
    result: {
      data: {
        teams: [teamMock],
        me: meMock,
      },
    },
  },
]

const PageComponent = () => (
  <I18nextProvider i18n={i18n}>
    <MockedProvider mocks={mocks} addTypename={false}>
      <MemoryRouter initialEntries={["/companies/taller/teams"]}>
        <Routes>
          <Route path="/companies/taller/teams" element={<Teams />} />
        </Routes>
      </MemoryRouter>
    </MockedProvider>
  </I18nextProvider>
)

describe("Teams Page", () => {
  it("should render a list of teams", async () => {
    const { getByText } = render(<PageComponent />)

    await waitFor(() => {
      const teamName = getByText(teamMock.name)
      expect(teamName).toBeInTheDocument()
    })
  })

  it("should render teams page in portuguese", async () => {
    const { getAllByText } = render(<PageComponent />)

    await waitFor(() => {
      const teams = getAllByText("Times")
      expect(teams[0]).toBeInTheDocument()
    })
  })

  it("should render teams page in english", async () => {
    const { getAllByText } = render(<PageComponent />)

    await waitFor(() => {
      i18n.changeLanguage("en")
      const teams = getAllByText("Teams")
      expect(teams[0]).toBeInTheDocument()
    })
  })
})
