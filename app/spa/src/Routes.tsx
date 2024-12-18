import {
  BrowserRouter,
  Route,
  Routes as ReactRouterRoutes,
} from "react-router-dom"
import TeamMembers from "./pages/TeamMembers/TeamMembers"
import TeamMemberDashboard from "./pages/TeamMembers/TeamMemberDashboard"
import EditTeamMember from "./pages/TeamMembers/EditTeamMember"
import Project from "./pages/Projects/Project"
import ProductPage from "./pages/Products/ProductPage"
import ProductsRiskReviews from "./pages/Products/ProductsRiskReviews"
import ServiceDeliveryReviews from "./pages/Products/ServiceDeliveryReviews"
import CreateProductRiskReview from "./pages/Products/CreateProductRiskReview"
import ShowProductsRiskReview from "./pages/Products/ShowProductsRiskReview"
import PortfolioUnitsPage from "./pages/Products/PortfolioUnitsPage"
import CreatePortfolioUnits from "./pages/Products/CreatePortfolioUnits"
import EditPortfolioUnits from "./pages/Products/EditPortfolioUnits"
import StatusReport from "./pages/Projects/StatusReport"
import RiskDrill from "./pages/Projects/RiskDrill"
import LeadTimeDashboard from "./pages/Projects/LeadTimeDashboard"
import Statistics from "./pages/Projects/Statistics"
import ProjectFinancialReport from "./pages/Projects/ProjectFinancialReport"
import CreateProjectAditionalHours from "./pages/Projects/CreateProjectAditionalHours"
import Teams from "./pages/Teams/Teams"
import CreateTeam from "./pages/Teams/CreateTeam"
import TeamDashboard from "./pages/Teams/TeamDashboard"
import MembershipsTable from "./pages/Teams/MembershipsTable"
import MemberEfficiencyTable from "./pages/Teams/MemberEfficiencyTable"
import MembershipForm from "./pages/Teams/MembershipForm"
import EditTeam from "./pages/Teams/EditTeam"
import Replenishing from "./pages/Teams/Replenishing"
import ProjectsPage from "./pages/Projects/ProjectsPage"
import DemandsPage from "./pages/Demand/DemandsList"
import DemandsCharts from "./pages/Demand/DemandsCharts"
import DemandEfforts from "./pages/Demand/DemandEfforts"
import ListWorkItemTypes from "./pages/WorkItemTypes/ListWorkItemTypes"
import CreateWorkItemType from "./pages/WorkItemTypes/CreateWorkItemType"
import CustomerDemand from "./pages/Customer/CustomerDemand"
import EditJiraProjectConfig from "./pages/Jira/EditJiraProjectConfig"
import JiraProjectConfigList from "./pages/Jira/JiraProjectConfigList"
import ManagerDashboard from "./pages/Users/ManagerDashboard"
import ProductUsersPage from "./pages/Products/ProductUsersPage"
import ServiceDeliveryReview from "./pages/Products/ServiceDeliveryReview"
import CreateDemandEffort from "./modules/demandEffort/components/CreateDemandEffort"

const Routes = () => {
  return (
    <BrowserRouter>
      <ReactRouterRoutes>
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
          path="/companies/:company/demands/:demand/demand_efforts/new"
          element={<CreateDemandEffort />}
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
        <Route
          path="/users/:userId/manager_home"
          element={<ManagerDashboard />}
        />
        <Route
          path="/companies/:companySlug/products/:productSlug/product_users"
          element={<ProductUsersPage />}
        />
      </ReactRouterRoutes>
    </BrowserRouter>
  )
}

export default Routes
