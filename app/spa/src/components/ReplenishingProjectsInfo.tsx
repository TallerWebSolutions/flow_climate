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
      <MaterialTableRow sx={{ backgroundColor: "grey.200" }}>
        <TableCell colSpan={10}>
          <Table>
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
              <Box
                sx={{
                  width: 3,
                  height: 3,
                  borderRadius: "50%",
                  backgroundColor: "yellow",
                }}
              />
              <TableCell>{project.remainingBacklog} demandas</TableCell>
              <TableCell>{project.flowPressurePercentage}</TableCell>
              <TableCell>{(project.leadTimeP80 / 86400).toFixed(2)}</TableCell>
              <TableCell>{project.qtyInProgress} demandas</TableCell>
              <TableCell>Início</TableCell>
              <TableCell>Fim</TableCell>
              <TableCell>{project.monteCarloP80}</TableCell>
            </MaterialTableRow>
            <MaterialTableRow>
              <TableCell>Cliente</TableCell>
              <TableCell>0,7</TableCell>
              <TableCell />
              <TableCell>{project.flowPressure.toFixed(2)}</TableCell>
            </MaterialTableRow>
          </Table>
        </TableCell>
      </MaterialTableRow>
      <MaterialTableRow>
        <TableCell style={{ paddingBottom: 0, paddingTop: 0 }}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Table sx={{ "td, th": { fontSize: ".7rem" } }}>
              <TableHead>
                <MaterialTableRow>
                  <TableCell>Limite Wip</TableCell>
                  <TableCell>TH última semana</TableCell>
                  <TableCell>Qtd Throughputs</TableCell>
                  <TableCell>Moda do throughput</TableCell>
                  <TableCell>Throughput std dev</TableCell>
                  <TableCell>Monte Carlo (80% - time)</TableCell>
                  <TableCell>MC - Min/Max/Std Dev</TableCell>
                  <TableCell>Chances de data (time)</TableCell>
                </MaterialTableRow>
              </TableHead>
              <TableBody>
                <MaterialTableRow>
                  <TableCell>{project.workInProgressLimit}</TableCell>
                  <TableCell>{project.lastWeekThroughput}</TableCell>
                  <TableCell>{`${project.qtyThroughputs} (${project.throughputsArray})`}</TableCell>
                  <TableCell>{project.modeWeeklyTroughputs}</TableCell>
                  <TableCell>
                    {project.stdDevWeeklyTroughputs.toFixed(2)}
                  </TableCell>
                  <TableCell>{`${project.teamMonteCarloP80} semanas`}</TableCell>
                  <TableCell>{`${project.teamMonteCarloWeeksMin}/${
                    project.teamMonteCarloWeeksMax
                  }/${project.teamMonteCarloWeeksStdDev.toFixed(
                    2
                  )}`}</TableCell>
                  <TableCell>{`${
                    project.teamBasedOddsToDeadline * 100
                  }%`}</TableCell>
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
