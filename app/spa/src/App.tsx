import { gql, useQuery } from "@apollo/client"
import { ConfirmProvider } from "material-ui-confirm"
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
import DemandsPage from "./pages/Demand/DemandsList"
import CreateTeam from "./pages/Teams/CreateTeam"
import EditTeam from "./pages/Teams/EditTeam"
import Teams from "./pages/Teams/Teams"
import TeamMembers from "./pages/TeamMembers/TeamMembers"
import TeamMemberDashboard from "./pages/TeamMembers/TeamMemberDashboard"
import EditTeamMember from "./pages/TeamMembers/EditTeamMember"
import User from "./modules/user/user.types"
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
import ShowProductsRiskReview from "./pages/Products/ShowProductsRiskReview"
import MemberEfficiencyTable from "./pages/Teams/MemberEfficiencyTable"
import PortfolioUnitsPage from "./pages/Products/PortfolioUnitsPage"
import MembershipForm from "./pages/Teams/MembershipForm"
import MembershipsTable from "./pages/Teams/MembershipsTable"
import CreatePortfolioUnits from "./pages/Products/CreatePortfolioUnits"
import EditPortfolioUnits from "./pages/Products/EditPortfolioUnits"
import ServiceDeliveryReviews from "./pages/Products/ServiceDeliveryReviews"
import ServiceDeliveryReview from "./pages/Products/ServiceDeliveryReview"
import EditJiraProjectConfig from "./pages/Jira/EditJiraProjectConfig"
import JiraProjectConfigList from "./pages/Jira/JiraProjectConfigList"

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
              path="/companies/:companySlug/products/:productSlug/service_delivery_reviews_tab"
              element={<ServiceDeliveryReviews />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/service_delivery_reviews/:reviewId"
              element={<ServiceDeliveryReview />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/risk_reviews/new"
              element={<CreateProductRiskReview />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/risk_reviews/:riskReviewId"
              element={<ShowProductsRiskReview />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/portfolio_units"
              element={<PortfolioUnitsPage />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/portfolio_units/new"
              element={<CreatePortfolioUnits />}
            />
            <Route
              path="/companies/:companySlug/products/:productSlug/portfolio_units/:unitId/edit"
              element={<EditPortfolioUnits />}
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
              element={<MembershipsTable />}
            />
            <Route
              path="/companies/:companySlug/teams/:teamId/memberships/efficiency_table"
              element={<MemberEfficiencyTable />}
            />
            <Route
              path="/companies/:companySlug/teams/:teamId/memberships/:membershipId/edit"
              element={<MembershipForm />}
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
            <Route
              path="/devise_customers/customer_demands/:demand/demand_efforts"
              element={<DemandEfforts />}
            />
            <Route
              path="/companies/:companyId/jira/projects/:projectId/jira_project_configs/:id/edit"
              element={<EditJiraProjectConfig />}
            />
            <Route
              path="/companies/:company_id/jira/projects/:project_id/jira_project_configs"
              element={<JiraProjectConfigList />}
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
