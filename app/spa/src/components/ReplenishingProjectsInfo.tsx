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
import { Box } from "@mui/system"
import { Fragment, useState } from "react"
import { Project } from "../modules/project/project.types"
import { secondsToReadbleDate } from "../lib/date"
import { KeyboardArrowDown, KeyboardArrowUp } from "@mui/icons-material"

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
        <TableCell>{secondsToReadbleDate(project.leadTimeP80)}</TableCell>
        <TableCell>{project.qtyInProgress} demandas</TableCell>
        <TableCell>{project.startDate}</TableCell>
        <TableCell>{project.endDate}</TableCell>
        <TableCell>{project.monteCarloP80.toFixed(2)}</TableCell>
      </MaterialTableRow>
      <MaterialTableRow sx={{ td: { color: "grwy.600" } }}>
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
        <TableCell>Limite de WiP: {project.maxWorkInProgress}</TableCell>
        <TableCell>Idade: {project.aging} dias</TableCell>
        <TableCell>Restante: {project.remainingWeeks} semanas</TableCell>
      </MaterialTableRow>
      <MaterialTableRow
        sx={{
          backgroundColor: "grwy.A100",
          borderBottom: "1px solid",
          borderBottomColor: "grwy.400",
        }}
      >
        <TableCell style={{ padding: 0 }} colSpan={10}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <Table>
              <TableBody>
                <MaterialTableRow>
                  <TableCell width={52} />
                  <TableCell sx={{ color: "grwy.600" }}>
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
                  <TableCell colSpan={2} sx={{ color: "grwy.600" }}>
                    Mín: {project.teamMonteCarloWeeksMin}
                  </TableCell>
                  <TableCell sx={{ color: "grwy.600" }}>
                    Monte Carlo 80%: {project.teamMonteCarloP80}
                  </TableCell>
                </MaterialTableRow>
                <MaterialTableRow>
                  <TableCell />
                  <TableCell />
                  <TableCell colSpan={4} sx={{ color: "grwy.600" }}>
                    Throughputs: ({project.weeklyThroughputs.join(", ")})
                  </TableCell>
                  <TableCell />
                  <TableCell colSpan={2} sx={{ color: "grwy.600" }}>
                    Máx: {project.teamMonteCarloWeeksMax}
                  </TableCell>
                  <TableCell sx={{ color: "grwy.600" }}>
                    Desvio padrão:{" "}
                    {project.teamMonteCarloWeeksStdDev.toFixed(2)}
                  </TableCell>
                </MaterialTableRow>
                <MaterialTableRow>
                  <TableCell />
                  <TableCell />
                  <TableCell />
                  <TableCell colSpan={5} sx={{ color: "grwy.600" }}>
                    Selecionadas: {project.qtySelected}
                  </TableCell>
                  <TableCell sx={{ color: "grwy.600" }}>
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
