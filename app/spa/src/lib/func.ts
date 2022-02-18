export const formatLeadtime = (leadtime: number): number =>
  Number((leadtime / 86400).toFixed(2))
