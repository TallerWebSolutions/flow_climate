import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow as MaterialTableRow,
  IconButton,
  Collapse,
} from "@mui/material"
import { KeyboardArrowUp, KeyboardArrowDown } from "@material-ui/icons"
import { Box } from "@mui/system"
import { Fragment, useState } from "react"

type Customer = {
  name: string
}

type Product = {
  name: string
}

export type Project = {
  id: number
  name: string
  remainingWeeks: number
  remainingBacklog: number
  flowPressure: number
  flowPressurePercentage: number
  leadTimeP80: number
  qtySelected: number
  qtyInProgress: number
  monteCarloP80: number
  workInProgressLimit: number
  lastWeekThroughput: number
  qtyThroughputs: number
  throughputsArray: number[]
  modeWeeklyTroughputs: number
  stdDevWeeklyTroughputs: number
  teamMonteCarloP80: number
  teamMonteCarloWeeksMin: number
  teamMonteCarloWeeksMax: number
  teamMonteCarloWeeksStdDev: number
  teamBasedOddsToDeadline: number
  customers: Customer[]
  products: Product[]
}

type ReplenishingProjectsInfoProps = {
  projects: Project[]
}

const tableHeadStyles = {
  backgroundColor: "secondary.main",
  th: {
    color: "secondary.contrastText",
  },
}

const TableRow = ({ project }: { project: Project }) => {
  const [open, setOpen] = useState(false)

  return (
    <Fragment>
      <MaterialTableRow>
        <TableCell>
          <IconButton
            aria-label="expand row"
            size="small"
            onClick={() => setOpen(!open)}
          >
            {open ? <KeyboardArrowUp /> : <KeyboardArrowDown />}
          </IconButton>
        </TableCell>
        <TableCell>{project.name}</TableCell>
        <TableCell>
          <Box
            sx={{
              width: "24px",
              height: "24px",
              borderRadius: "50%",
              backgroundColor: "yellow",
            }}
          />
        </TableCell>
        <TableCell>{project.remainingBacklog} demandas</TableCell>
        <TableCell>{project.flowPressurePercentage}</TableCell>
        <TableCell>{(project.leadTimeP80 / 86400).toFixed(2)}</TableCell>
        <TableCell>{project.qtyInProgress} demandas</TableCell>
        <TableCell>Início</TableCell>
        <TableCell>Fim</TableCell>
        <TableCell>{project.monteCarloP80}</TableCell>
      </MaterialTableRow>
      <MaterialTableRow>
        <TableCell />
        <TableCell>
          {project.customers.map(({ name }) => name).join(", ")}
        </TableCell>
        <TableCell>0,7</TableCell>
        <TableCell />
        <TableCell>{project.flowPressure.toFixed(2)}</TableCell>
        <TableCell />
        <TableCell>{project.workInProgressLimit}</TableCell>
        <TableCell>Idade: X dias</TableCell>
        <TableCell>Restante: X dias</TableCell>
      </MaterialTableRow>
      <MaterialTableRow>
        <TableCell style={{ paddingBottom: 0, paddingTop: 0 }} colSpan={10}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Table sx={{ "td, th": { fontSize: ".7rem" } }}>
              <TableBody>
                <MaterialTableRow>
                  <TableCell />
                  <TableCell>
                    {project.products.map(({ name }) => name).join(", ")}
                  </TableCell>
                  <TableCell colSpan={4}>Dados do projeto:</TableCell>
                  <TableCell>Dados do time:</TableCell>
                  <TableCell colSpan={2}>
                    Mín: {project.teamMonteCarloWeeksMin}
                  </TableCell>
                  <TableCell>
                    Monte Carlo 80%: {project.teamMonteCarloP80}
                  </TableCell>
                </MaterialTableRow>
                <MaterialTableRow>
                  <TableCell />
                  <TableCell />
                  <TableCell colSpan={4}>
                    Throughputs: ({project.throughputsArray})
                  </TableCell>
                  <TableCell />
                  <TableCell colSpan={2}>
                    Máx: {project.teamMonteCarloWeeksMax}
                  </TableCell>
                  <TableCell>Desvio padrão: X</TableCell>
                </MaterialTableRow>
                <MaterialTableRow>
                  <TableCell />
                  <TableCell />
                  <TableCell />
                  <TableCell colSpan={5}>
                    Selecionadas: {project.qtySelected}
                  </TableCell>
                  <TableCell>
                    Chances da data: {project.teamBasedOddsToDeadline * 100}%
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
}: ReplenishingProjectsInfoProps) => (
  <Box my={1}>
    <TableContainer>
      <Table>
        <TableHead sx={tableHeadStyles}>
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
            <TableRow project={project} key={`${project.id}__${index}`} />
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  </Box>
)

export default ReplenishingProjectsInfo
