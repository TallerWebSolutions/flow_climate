import TicketGroup from "../../../components/TicketGroup"

const ProjectMonteCarloData = ({
  currentMonteCarloWeeksMin,
  currentMonteCarloWeeksMax,
  monteCarloP80,
  currentMonteCarloWeeksStdDev,
}: ProjectMonteCarloDataProps) => {
  const monteCarloProject = [
    {
      title: "Mínimo",
      value: currentMonteCarloWeeksMin,
      unity: "semanas",
    },
    {
      title: "Máximo",
      value: currentMonteCarloWeeksMax,
      unity: "semanas",
    },
    {
      title: "Percentil 80",
      value: monteCarloP80?.toFixed(2),
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: currentMonteCarloWeeksStdDev?.toFixed(2),
      unity: "semanas",
    },
  ]

  return <TicketGroup title="Monte Carlo (Projeto)" data={monteCarloProject} />
}

// Receiving each prop instead of Project because a ProjectSimulation can also be used.
type ProjectMonteCarloDataProps = {
  currentMonteCarloWeeksMin: number
  currentMonteCarloWeeksMax: number
  monteCarloP80: number
  currentMonteCarloWeeksStdDev: number
}

export default ProjectMonteCarloData
