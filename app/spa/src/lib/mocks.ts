export const projectMock = {
  id: "1",
  name: "Project X",
  remainingWeeks: 10,
  remainingBacklog: 20,
  flowPressure: 12,
  flowPressurePercentage: 43,
  leadTimeP80: 32,
  qtySelected: 8,
  qtyInProgress: 9,
  monteCarloP80: 89,
  workInProgressLimit: 9,
  lastWeekThroughput: 54,
  weeklyThroughputs: [0, 1, 2, 3, 4, 3],
  modeWeeklyTroughputs: 3,
  stdDevWeeklyTroughputs: 4,
  teamMonteCarloP80: 3,
  teamMonteCarloWeeksMin: 1,
  teamMonteCarloWeeksMax: 9,
  teamMonteCarloWeeksStdDev: 3,
  teamBasedOddsToDeadline: 4.9999999999,
  customerHappiness: 1,
  startDate: "11/11/11",
  endDate: "12/12/12",
  aging: 5,
  customers: [],
  products: [],
}

export const teamMock = {
  id: "1",
  name: "Vingadores",
  increasedLeadtime80: false,
  throughputData: [1, 2, 3, 4, 5],
  averageThroughput: 3,
  increasedAvgThroughtput: true,
  leadTime: 10,
  workInProgress: 10,
  company: {
    id: "1",
    name: "Taller",
    slug: "taller",
  },
  lastReplenishingConsolidations: [
    {
      id: "1",
      consolidationDate: "11/11/11",
      createdAt: "11/11/11",
      project: projectMock,
      customerHappiness: 1,
    },
  ],
}

export const replenishingMock = {
  team: teamMock,
  me: {
    id: "1",
    fullName: "John Doe",
    avatar: {
      imageSource: "lorempixel.com/100/100",
    },
  },
}