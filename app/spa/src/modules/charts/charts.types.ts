export type NumberChartData = {
  xAxis: (string | number)[]
  yAxis: number[]
}

export type ChartAxisData = {
  xAxis: (string | number)[]
  yAxis: (string | number)[]
  leadTimeP65?: number
  leadTimeP80?: number
  leadTimeP95?: number
}

export type DemandsFlowChartData = {
  xAxis?: string[]
  creationChartData?: number[]
  committedChartData?: number[]
  pullTransactionRate?: number[]
  throughputChartData?: number[]
}

export type KeyValueData = {
  keys: (number | string)[]
  values: (number | string)[]
}

export type SimpleChartData = {
  label: string
  value: number
}

export type SimpleListChartData = {
  name: string
  data: number[]
}
