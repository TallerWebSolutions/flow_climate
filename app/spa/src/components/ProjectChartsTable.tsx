import { Grid, TableContainer, Paper, Link, Typography, Box, Table, TableRow, TableCell, TableHead, TableBody } from "@mui/material"
import { useState } from "react"
import { useTranslation } from "react-i18next"
import { formatDate, secondsToReadbleDate } from "../lib/date"
import { Demand } from "../modules/demand/demand.types"
import { Project } from "../modules/project/project.types"
import { ReadMoreButton } from "./ReadMoreButton"

type ProjectChartsTableProps = {
  project: Project
  demands: Demand[]
}

export const ProjectChartsTable = ({project, demands}:ProjectChartsTableProps) => {
  const { t } = useTranslation(["projectChart"])
  const [readMore, setReadMore] = useState(true)

  return (
  <Grid container spacing={2} sx={{marginTop: '32px'}}>
        <Grid item xs={4} sx={{ padding: '16px '}}>
        <TableContainer component={Paper} sx={{ background: "white" }}>
          <Typography color="primary" variant="h6" component="h6" sx={{ padding: '16px '}}>
            Informações gerais
          </Typography>
          <Box sx={{
            position: 'relative',
            height: readMore ? '570px' : 'auto',
            overflow: readMore ? 'hidden' : '',
          }}>
            <Table>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Início</Box>
                  {formatDate({ date: project.startDate, format: "dd/MM/yyyy" })}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Fim</Box>
                  {formatDate({ date: project.endDate, format: "dd/MM/yyyy" })}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Escopo inicial</Box>
                  {project.initialScope}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Demandas Criadas</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.numberOfDemands}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Entregas</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.numberOfDemandsDelivered}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Backlog</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.remainingBacklog}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Upstream</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.upstreamDemands.length}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Downstream</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.numberOfDownstreamDemands}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Descartadas</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.discardedDemands.length}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Demandas sem Pontuação</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.unscoredDemands.length}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Bloqueios</Box>
                  <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.demandBlocks.length}</Link>
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Pressão do Fluxo</Box>
                  {`${secondsToReadbleDate(project.flowPressure, 'demandas/')}`}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Velocidade Média</Box>
                  {`${project.averageSpeed.toFixed(3)} demandas/dia`}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Tempo Médio de Fila</Box>
                  {`${project.averageQueueTime.toFixed(2)} horas`}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Tempo Médio de Trabalho</Box>
                  {`${project.averageTouchTime.toFixed(2)} horas`}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Lead time p95</Box>
                  {`${project.leadTimeP95.toFixed(2)} dias`}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Lead time p80</Box>
                  {`${project.leadTimeP80.toFixed(2)} dias`}
                </TableCell>
              </TableRow>
              <TableRow
                sx={{
                  borderBottom: "1px solid",
                  borderBottomColor: "#ccc",                
                }}
              >
                <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                  <Box component="span">Lead time p65</Box>
                  {`${project.leadTimeP65.toFixed(2)} dias`}
                </TableCell>
              </TableRow>
            </Table>          
          {readMore && <ReadMoreButton handleDisplayPostContent={() => setReadMore(false)} />}
          </Box>
        </TableContainer>
        </Grid>
        <Grid item xs={8} sx={{ padding: '16px '}}>
        <TableContainer component={Paper} sx={{ background: "white" }}>
        <Typography color="primary" variant="h6" component="h6" sx={{ padding: '16px '}}>
          {t('project_chart_table.latest_deliveries')}
        </Typography>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('project_chart_table.client')}</TableCell>
                <TableCell align="left">{t('project_chart_table.product')}</TableCell>
                <TableCell align="left">{t('project_chart_table.demand_id')}</TableCell>
                <TableCell align="left">{t('project_chart_table.delivery_date')}</TableCell>
                <TableCell align="left">{t('project_chart_table.leadtime')}</TableCell>
                <TableCell align="left">{t('project_chart_table.demand_blocks')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              
              {demands.map((demand) => {
                const baseLink = `/companies/${project?.company?.slug}`

                return (
                  <TableRow
                    sx={{
                      borderBottom: "1px solid",
                      borderBottomColor: "#ccc",
                    }}
                  >
                    <TableCell align="left" sx={{padding: '16px'}}>
                      <Link href={`${baseLink}/projects/${project.id}`} sx={{color: 'info.dark', textDecoration: 'none'}} >{demand.customer.name}</Link>
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                    <Link href={`${baseLink}/products/${demand.product.id}`} sx={{color: 'info.dark', textDecoration: 'none'}}>{demand.product.name}</Link>
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                    <Link href={`${baseLink}/demands/${demand.externalId}`} sx={{color: 'info.dark', textDecoration: 'none'}}>{demand.externalId}</Link>
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                      {formatDate({date: demand.endDate, format: "dd/MM/yyyy' 'HH:mm:ss"})}
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                      {secondsToReadbleDate(demand.leadtime)}
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                      {demand.numberOfBlocks}
                    </TableCell>
                </TableRow>
                )
              })} 
            </TableBody>
          </Table>        
        </TableContainer>
        </Grid>
    </Grid>
  )
}