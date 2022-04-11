import { MockedProvider } from "@apollo/client/testing"
import {
  fireEvent,
  render,
  RenderResult,
  waitFor,
  within,
} from "@testing-library/react"
import { act } from "react-dom/test-utils"
import { I18nextProvider } from "react-i18next"
import { MemoryRouter, Route, Routes } from "react-router-dom"
import i18n from "../../lib/i18n"
import { tasksMock, tasksSelectsMock } from "../../lib/mocks"
import { TASKS_LIST_QUERY } from "../Tasks/List"
import TasksPage, { SELECT_FILTERS_QUERY } from "../Tasks/Tasks"

export type TaskFilters = {
  page: number
  limit: number
  status?: string
  title?: string
  teamId?: string
  projectId?: string
  initiativeId?: string
  fromDate?: string | null
  untilDate?: string | null
}

const mountTaskPage = (mocks: any) => {
  return render(
    <I18nextProvider i18n={i18n}>
      <MockedProvider mocks={mocks} addTypename={false}>
        <MemoryRouter initialEntries={["/companies/taller/tasks"]}>
          <Routes>
            <Route
              path="/companies/:companyNickName/tasks"
              element={<TasksPage />}
            />
          </Routes>
        </MemoryRouter>
      </MockedProvider>
    </I18nextProvider>
  )
}

describe("pages/Task/List", () => {
  describe("table rendering", () => {
    it("should render task table from query data", async () => {
      const mocks = [
        {
          request: {
            query: SELECT_FILTERS_QUERY,
          },
          result: { ...tasksSelectsMock },
        },
        {
          request: {
            query: TASKS_LIST_QUERY,
            variables: {
              limit: 10,
              page: 0,
            },
          },
          result: { ...tasksMock },
        },
      ]

      let container: RenderResult
      act(() => {
        container = mountTaskPage(mocks)
      })

      const taskList = await container.findByTestId("task-list")

      await waitFor(
        async () => {
          const rowsOnTaskTable = within(taskList).queryAllByRole("row")
          const quantityOfRowsInHeader = 1
          const quantityOfRowsOnTablesTRask =
            tasksMock.data.tasksList.tasks.length + quantityOfRowsInHeader

          expect(rowsOnTaskTable).toHaveLength(quantityOfRowsOnTablesTRask)
        },
        { timeout: 5000 }
      ),
        5000
    })
  })

  describe("table filtering", () => {
    it("should filter the task table from a project", async () => {
      const mocks = [
        {
          request: {
            query: SELECT_FILTERS_QUERY,
          },
          result: { ...tasksSelectsMock },
        },
        {
          request: {
            query: TASKS_LIST_QUERY,
            variables: {
              limit: 10,
              page: 0,
            },
          },
          result: { ...tasksMock },
        },
      ]

      let container: RenderResult
      act(() => {
        container = mountTaskPage(mocks)
      })

      const projectIdToBeSelected = "1"
      const taskList = await container.findByTestId("task-list")
      const selectProjectComponent = await container.findByTestId(
        "select-project"
      )

      act(() => {
        fireEvent.change(selectProjectComponent, {
          target: { value: projectIdToBeSelected },
        })
      })

      await waitFor(
        async () => {
          const rowsOnTaskTable = within(taskList).queryAllByRole("row")
          const quantityOfRowsInHeader = 1
          const quantityOfRowsOnTablesTRask =
            tasksMock.data.tasksList.tasks.length + quantityOfRowsInHeader

          expect(rowsOnTaskTable).toHaveLength(quantityOfRowsOnTablesTRask)
        },
        { timeout: 5000 }
      )
    }, 5000)
  })
})
