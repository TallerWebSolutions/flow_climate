import { gql, useQuery } from "@apollo/client"
import { ConfirmProvider } from "material-ui-confirm"
import { Backdrop, CircularProgress } from "@mui/material"
import { Fragment, useEffect } from "react"
import { Helmet } from "react-helmet"
import { I18nextProvider } from "react-i18next"
import { BrowserRouter, Route, Routes } from "react-router-dom"

import { MessagesContext } from "./contexts/MessageContext"
import { MeContext } from "./contexts/MeContext"
import { useMessages } from "./hooks/useMessages"
import ApiProvider from "./lib/ApiProvider"
import i18n, { loadLanguage } from "./lib/i18n"
import ThemeProvider from "./lib/ThemeProvider"
import LeadTimeDashboard from "./pages/Projects/LeadTimeDashboard"
import Project from "./pages/Projects/Project"
import ProjectFinancialReport from "./pages/Projects/ProjectFinancialReport"
import Replenishing from "./pages/Teams/Replenishing"
import RiskDrill from "./pages/Projects/RiskDrill"
import Statistics from "./pages/Projects/Statistics"
import StatusReport from "./pages/Projects/StatusReport"
import CreateProjectAditionalHours from "./pages/Projects/CreateProjectAditionalHours"
import TasksPage from "./pages/Tasks/TasksPage"
import DemandsPage from "./pages/Demand/DemandsList"
import TasksCharts from "./modules/task/components/TasksCharts"
import CreateTeam from "./pages/Teams/CreateTeam"
import EditTeam from "./pages/Teams/EditTeam"
import Teams from "./pages/Teams/Teams"
import TeamMembers from "./pages/TeamMembers/TeamMembers"
import TeamMemberDashboard from "./pages/TeamMembers/TeamMemberDashboard"
import EditTeamMember from "./pages/TeamMembers/EditTeamMember"
import User from "./modules/user/user.types"
import InitiativesList from "./pages/Initiatives/InitiativesList"
import EditInitiative from "./pages/Initiatives/EditInitiative"
import ProjectTasksCharts from "./pages/Projects/ProjectTasksCharts"
import DemandsCharts from "./pages/Demand/DemandsCharts"
import CreateWorkItemType from "./pages/WorkItemTypes/CreateWorkItemType"
import ListWorkItemTypes from "./pages/WorkItemTypes/ListWorkItemTypes"
import TeamDashboard from "./pages/Teams/TeamDashboard"
import ProductPage from "./pages/Products/ProductPage"
import ProjectsPage from "./pages/Projects/ProjectsPage"
import CustomerDemand from "./pages/Customer/CustomerDemand"
import DemandEfforts from "./pages/Demand/DemandEfforts"
import ProductsRiskReviews from "./pages/Products/ProductsRiskReviews"
import CreateProductRiskReview from "./pages/Products/CreateProductRiskReview"
import MembershipTable from "./pages/Teams/MembershipTable"
import PortfolioUnitsPage from "./pages/Products/PortfolioUnitsPage"

export const ME_QUERY = gql`
  query Me {
    me {
      id
      language
      currentCompany {
        id
        name
        slug
        workItemTypes {
          id
          name
        }
        initiatives {
          id
          name
        }
        projects {
          id
          name
        }
        teams {
          id
          name
        }
      }
      fullName
      avatar {
        imageSource
      }
      admin
      companies {
        id
        name
        slug
      }
    }
  }
`

type MeDTO = {
  me: User
}

const App = () => {
  const { data, loading } = useQuery<MeDTO>(ME_QUERY, {
    notifyOnNetworkStatusChange: true,
  })

  useEffect(() => {
    if (!loading) loadLanguage(data?.me.language)
  }, [data, loading])

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <Fragment>
      <Helmet>
        <title>Flow Climate - Mastering the flow management</title>
      </Helmet>
      <MeContext.Provider value={{ me: data?.me }}>
        <BrowserRouter>
          <Routes>
            <Route
              path="/companies/:companySlug/team_members"
              element={<TeamMembers />}
            />
            <Route
              path="/companies/:companySlug/team_members/:teamMemberId"
              element={<TeamMemberDashboard />}
            />
            <Route
              path="/companies/:companySlug/team_members/:teamMemberId/edit"
              element={<EditTeamMember />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId"
              element={<Project />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug"
              element={<ProductPage />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/risk_reviews_tab"
              element={<ProductsRiskReviews />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/risk_reviews/new"
              element={<CreateProductRiskReview />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/portfolio_units"
              element={<PortfolioUnitsPage />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId/tasks_tab"
              element={<ProjectTasksCharts />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId/status_report_dashboard"
              element={<StatusReport />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId/risk_drill_down"
              element={<RiskDrill />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId/lead_time_dashboard"
              element={<LeadTimeDashboard />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId/statistics_tab"
              element={<Statistics />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId/financial_report"
              element={<ProjectFinancialReport />}
            />
            <Route
              path="/companies/:companySlug/projects/:projectId/project_additional_hours/new"
              element={<CreateProjectAditionalHours />}
            />
            <Route path="/companies/:companySlug/teams" element={<Teams />} />
            <Route
              path="/companies/:companySlug/teams/new"
              element={<CreateTeam />}
            />
            <Route
              path="/companies/:companySlug/teams/:teamId"
              element={<TeamDashboard />}
            />
            <Route
              path="/companies/:companySlug/teams/:teamId/memberships"
              element={<MembershipTable />}
            />
            <Route
              path="/companies/:companySlug/teams/:teamId/edit"
              element={<EditTeam />}
            />
            <Route
              path="/companies/:companySlug/teams/:teamId/replenishing_consolidations"
              element={<Replenishing />}
            />
            <Route
              path="/companies/:companySlug/tasks"
              element={<TasksPage />}
            />
            <Route
              path="/companies/:companySlug/tasks/charts"
              element={<TasksCharts />}
            />
            <Route
              path="/companies/:companySlug/initiatives"
              element={<InitiativesList />}
            />
            <Route
              path="/companies/:companySlug/initiatives/:initiativeId/edit"
              element={<EditInitiative />}
            />
            <Route
              path="/companies/:companySlug/projects"
              element={<ProjectsPage />}
            />
            <Route
              path="/companies/:companySlug/demands"
              element={<DemandsPage />}
            />
            <Route
              path="/companies/:companySlug/demands/demands_charts"
              element={<DemandsCharts />}
            />
            <Route
              path="/companies/:company/demands/:demand/demand_efforts"
              element={<DemandEfforts />}
            />
            <Route
              path="/companies/:companySlug/work_item_types"
              element={<ListWorkItemTypes />}
            />
            <Route
              path="/companies/:companySlug/work_item_types/new"
              element={<CreateWorkItemType />}
            />
            <Route
              path="/devise_customers/customer_demands/:demand"
              element={<CustomerDemand />}
            />
          </Routes>
        </BrowserRouter>
      </MeContext.Provider>
    </Fragment>
  )
}

const AppWithProviders = () => {
  const [messages, pushMessage] = useMessages()
  const userProfile = window?.location?.pathname?.includes("devise_customers")
    ? "customer"
    : "user"

  return (
    <ApiProvider userProfile={userProfile}>
      <ThemeProvider>
        <ConfirmProvider>
          <MessagesContext.Provider value={{ messages, pushMessage }}>
            <I18nextProvider i18n={i18n}>
              <App />
            </I18nextProvider>
          </MessagesContext.Provider>
        </ConfirmProvider>
      </ThemeProvider>
    </ApiProvider>
  )
}

export default AppWithProviders
