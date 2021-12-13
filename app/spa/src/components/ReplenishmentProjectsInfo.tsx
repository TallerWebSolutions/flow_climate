import {
  Table,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from "@mui/material"

export type Project = any

type ReplenishingProjectsInfoProps = {
  projects: Project[]
}

const ReplenishingProjectsInfo = ({
  projects,
}: ReplenishingProjectsInfoProps) => (
  <TableContainer>
    <Table>
      <TableHead>
        <TableRow>
          <TableCell>Nome</TableCell>
          <TableCell>Semanas Restantes</TableCell>
          <TableCell>Backlog</TableCell>
          <TableCell>Pressão do Fluxo</TableCell>
          <TableCell>% Pressão do Fluxo</TableCell>
          <TableCell>Lead time (80%)</TableCell>
          <TableCell>Selecionadas</TableCell>
          <TableCell>WiP</TableCell>
          <TableCell>Monte Carlo (80%)</TableCell>
        </TableRow>
      </TableHead>
    </Table>
  </TableContainer>
)

export default ReplenishingProjectsInfo
