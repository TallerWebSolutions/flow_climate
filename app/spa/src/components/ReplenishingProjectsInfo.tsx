import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow as MaterialTableRow,
  IconButton,
  Collapse,
  Link,
} from "@mui/material"
import { KeyboardArrowUp, KeyboardArrowDown } from "@material-ui/icons"
import { Box } from "@mui/system"
import { Fragment, useState } from "react"
import { Company } from "../modules/company/company.types"
import { formatLeadtime } from "../lib/func"

type Customer = {
  id: string
  name: string
}

type Product = {
  id: string
  name: string
}

export type ProjectConsolidation = {
  leadTimeMin: number
  leadTimeMax: number
  leadTimeP80: number
  leadTimeFeature: number
  leadTimeBug: number
  leadTimeChore: number
  leadTimeStandard: number
  leadTimeFixedDate: number
  leadTimeExpedite: number
  leadTimeStdDev: number
  leadTimeAverage: number
  demandsFinishedIds: number[]
  leadTimeHistogramBinMin: number
  leadTimeHistogramBinMax: number
  leadTimeRangeMonth: number
  leadTimeMinMonth: number
  leadTimeMaxMonth: number
  histogramRange: number
  interquartileRange: number
  leadTimeP25: number
  leadTimeP75: number
}

export type Project = {
  id: string
  name: string
  remainingWeeks: number
  remainingBacklog: number
  backlogCountFor: number
  flowPressure: number
  flowPressurePercentage: number
  pastWeeks: number
  remainingWork: number
  leadTimeP80: number
  qtySelected: number
  qtyInProgress: number
  monteCarloP80: number
  workInProgressLimit: number
  lastWeekThroughput: number
  weeklyThroughputs: number[]
  modeWeeklyTroughputs: number
  stdDevWeeklyTroughputs: number
  currentMonteCarloWeeksMin: number
  currentMonteCarloWeeksMax: number
  currentMonteCarloWeeksStdDev: number
  currentWeeksByLittleLaw: number
  teamMonteCarloP80: number
  teamMonteCarloWeeksMin: number
  teamMonteCarloWeeksMax: number
  teamMonteCarloWeeksStdDev: number
  teamBasedOddsToDeadline: number
  customers: Customer[]
  products: Product[]
  customerHappiness: number
  startDate: string
  endDate: string
  aging: number
  company: Company
  firstDeadline: string
  daysDifferenceBetweenFirstAndLastDeadlines: number
  deadlinesChangeCount: number
  currentCost: number
  totalHoursConsumed: number
  averageSpeed: number
  averageDemandAging: number
  totalThroughput: number
  failureLoad: number
  discoveredScope: number
  scope: number
  projectConsolidations: ProjectConsolidation[]
  currentRiskToDeadline: number
  remainingDays: number
  currentTeamBasedRisk: number
  running: boolean
}

type ReplenishingProjectsInfoProps = {
  projects: Project[]
  companySlug: string
}

const getCustomerHappinessColor = (customerHappiness: number) =>
  customerHappiness > 2
    ? "success.main"
    : customerHappiness > 0.8
    ? "warning.main"
    : "error.main"

type TableRowProps = { project: Project; companySlug: string }

const TableRow = ({ project, companySlug }: TableRowProps) => {
  const [open, setOpen] = useState(false)

  return (
    <Fragment>
      <MaterialTableRow
        sx={{
          td: {
            color: "primary.main",
            paddingBottom: 0,
          },
        }}
      >
        <TableCell width={52}>
          <IconButton
            aria-label="expand row"
            size="small"
            onClick={() => setOpen(!open)}
          >
            {open ? <KeyboardArrowUp /> : <KeyboardArrowDown />}
          </IconButton>
        </TableCell>
        <TableCell>
          <Link href={`/companies/${companySlug}/projects/${project.id}`}>
            {project.name}
          </Link>
        </TableCell>
        <TableCell>
          <Box
            sx={{
              width: "24px",
              height: "24px",
              borderRadius: "50%",
              backgroundColor: getCustomerHappinessColor(
                project.customerHappiness
              ),
            }}
          />
        </TableCell>
        <TableCell>{project.remainingBacklog} demandas</TableCell>
        <TableCell>{project.flowPressurePercentage.toFixed(2)}%</TableCell>
        <TableCell>{formatLeadtime(project.leadTimeP80)}</TableCell>
        <TableCell>{project.qtyInProgress} demandas</TableCell>
        <TableCell>{project.startDate}</TableCell>
        <TableCell>{project.endDate}</TableCell>
        <TableCell>{project.monteCarloP80.toFixed(2)}</TableCell>
      </MaterialTableRow>
      <MaterialTableRow sx={{ td: { color: "grey.600" } }}>
        <TableCell width={52} />
        <TableCell>
          {project.customers.map(({ name, id }) => (
            <Link href={`/companies/${companySlug}/customers/${id}`}>
              {name}
            </Link>
          ))}
        </TableCell>
        <TableCell>{project.customerHappiness.toFixed(2)}</TableCell>
        <TableCell />
        <TableCell>{project.flowPressure.toFixed(2)}</TableCell>
        <TableCell />
        <TableCell>Limite de WiP: {project.workInProgressLimit}</TableCell>
        <TableCell>Idade: {project.aging} dias</TableCell>
        <TableCell>Restante: {project.remainingWeeks} semanas</TableCell>
      </MaterialTableRow>
      <MaterialTableRow
        sx={{
          backgroundColor: "grey.A100",
          borderBottom: "1px solid",
          borderBottomColor: "grey.400",
        }}
      >
        <TableCell style={{ padding: 0 }} colSpan={10}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Table>
              <TableBody>
                <MaterialTableRow>
                  <TableCell width={52} />
                  <TableCell sx={{ color: "grey.600" }}>
                    {project.products.map(({ name, id }) => (
                      <Link href={`/companies/${companySlug}/products/${id}`}>
                        {name}
                      </Link>
                    ))}
                  </TableCell>
                  <TableCell sx={{ color: "primary.main" }} colSpan={4}>
                    Dados do projeto:
                  </TableCell>
                  <TableCell sx={{ color: "primary.main" }}>
                    Dados do time:
                  </TableCell>
                  <TableCell colSpan={2} sx={{ color: "grey.600" }}>
                    Mín: {project.teamMonteCarloWeeksMin}
                  </TableCell>
                  <TableCell sx={{ color: "grey.600" }}>
                    Monte Carlo 80%: {project.teamMonteCarloP80}
                  </TableCell>
                </MaterialTableRow>
                <MaterialTableRow>
                  <TableCell />
                  <TableCell />
                  <TableCell colSpan={4} sx={{ color: "grey.600" }}>
                    Throughputs: ({project.weeklyThroughputs.join(", ")})
                  </TableCell>
                  <TableCell />
                  <TableCell colSpan={2} sx={{ color: "grey.600" }}>
                    Máx: {project.teamMonteCarloWeeksMax}
                  </TableCell>
                  <TableCell sx={{ color: "grey.600" }}>
                    Desvio padrão:{" "}
                    {project.teamMonteCarloWeeksStdDev.toFixed(2)}
                  </TableCell>
                </MaterialTableRow>
                <MaterialTableRow>
                  <TableCell />
                  <TableCell />
                  <TableCell />
                  <TableCell colSpan={5} sx={{ color: "grey.600" }}>
                    Selecionadas: {project.qtySelected}
                  </TableCell>
                  <TableCell sx={{ color: "grey.600" }}>
                    Chances da data:{" "}
                    {(project.teamBasedOddsToDeadline * 100).toFixed(2)}%
                  </TableCell>
                </MaterialTableRow>
              </TableBody>
            </Table>
          </Collapse>
        </TableCell>
      </MaterialTableRow>
    </Fragment>
  )
}

const ReplenishingProjectsInfo = ({
  projects,
  companySlug,
}: ReplenishingProjectsInfoProps) => (
  <Box my={1}>
    <TableContainer>
      <Table>
        <TableHead
          sx={{
            backgroundColor: "primary.light",
            th: {
              color: "white",
              paddingY: 2,
            },
          }}
        >
          <MaterialTableRow>
            <TableCell />
            <TableCell>Nome</TableCell>
            <TableCell>Fator</TableCell>
            <TableCell>Backlog</TableCell>
            <TableCell>Pressão do Fluxo</TableCell>
            <TableCell>Lead time (80%)</TableCell>
            <TableCell>WiP</TableCell>
            <TableCell>Início</TableCell>
            <TableCell>Fim</TableCell>
            <TableCell>Monte Carlo (80%)</TableCell>
          </MaterialTableRow>
        </TableHead>
        <TableBody>
          {projects.map((project, index) => (
            <TableRow
              project={project}
              companySlug={companySlug}
              key={`${project.id}__${index}`}
            />
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  </Box>
)

export default ReplenishingProjectsInfo
