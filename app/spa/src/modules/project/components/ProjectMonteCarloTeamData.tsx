import TicketGroup from "../../../components/TicketGroup"

const ProjectMonteCarloTeamData = ({
  teamMonteCarloWeeksMin,
  teamMonteCarloWeeksMax,
  teamMonteCarloP80,
  teamMonteCarloWeeksStdDev,
}: ProjectMonteCarloTeamDataProps) => {
  const monteCarloTeam = [
    {
      title: "Mínimo",
      value: teamMonteCarloWeeksMin,
      unity: "semanas",
    },
    {
      title: "Máximo",
      value: teamMonteCarloWeeksMax,
      unity: "semanas",
    },
    {
      title: "Percentil 80",
      value: teamMonteCarloP80?.toFixed(2),
      unity: "semanas",
    },
    {
      title: "Desvio padrão",
      value: teamMonteCarloWeeksStdDev?.toFixed(2),
      unity: "semanas",
    },
  ]

  return <TicketGroup title="Monte Carlo (Time)" data={monteCarloTeam} />
}

// Receiving each prop instead of Project because a ProjectSimulation can also be used.
type ProjectMonteCarloTeamDataProps = {
  teamMonteCarloWeeksMin: number
  teamMonteCarloWeeksMax: number
  teamMonteCarloP80: number
  teamMonteCarloWeeksStdDev: number
}

export default ProjectMonteCarloTeamData
