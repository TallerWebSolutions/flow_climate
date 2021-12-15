import {
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from "@mui/material"
import { Box } from "@mui/system"

export type Project = {
  name: string
  remainingWeeks: number
  remainingBacklog: number
  flowPressure: number
  flowPressurePercentage: number
  leadTimeP80: number
  qtySelected: number
  qtyInProgress: number
  monteCarloP80: number
}

type ReplenishingProjectsInfoProps = {
  projects: Project[]
}

const tableHeadStyles = {
  backgroundColor: "black",
  th: {
    color: "white",
  },
}

const ReplenishingProjectsInfo = ({
  projects,
}: ReplenishingProjectsInfoProps) => (
  <Box my={1}>
    <TableContainer>
      <Table>
        <TableHead sx={tableHeadStyles}>
          <TableRow>
            <TableCell>Nome</TableCell>
            <TableCell align="right">Semanas Restantes</TableCell>
            <TableCell align="right">Backlog</TableCell>
            <TableCell align="right">Pressão do Fluxo</TableCell>
            <TableCell align="right">% Pressão do Fluxo</TableCell>
            <TableCell align="right">Lead time (80%)</TableCell>
            <TableCell align="right">Selecionadas</TableCell>
            <TableCell align="right">WiP</TableCell>
            <TableCell align="right">Monte Carlo (80%)</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {projects.map((project) => (
            <TableRow>
              <TableCell>{project.name}</TableCell>
              <TableCell align="right">{project.remainingWeeks}</TableCell>
              <TableCell align="right">{project.remainingBacklog}</TableCell>
              <TableCell align="right">{project.flowPressure.toFixed(2)}</TableCell>
              <TableCell align="right">
                {project.flowPressurePercentage}
              </TableCell>
              <TableCell align="right">{(project.leadTimeP80 / 86400).toFixed(2)}</TableCell>
              <TableCell align="right">{project.qtySelected}</TableCell>
              <TableCell align="right">{project.qtyInProgress}</TableCell>
              <TableCell align="right">{project.monteCarloP80}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  </Box>
)

export default ReplenishingProjectsInfo
