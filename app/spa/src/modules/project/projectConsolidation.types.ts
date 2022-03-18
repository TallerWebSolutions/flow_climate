export type ProjectConsolidation = {
  leadTimeMin: number
  leadTimeMax: number
  leadTimeP80: number
  leadTimeFeature: number
  leadTimeBug: number
  leadTimeChore: number
  leadTimeStandard: number
  leadTimeFixedDate: number
  leadTimeExpedite: number
  leadTimeStdDev: number
  leadTimeAverage: number
  demandsFinishedIds: number[]
  leadTimeHistogramBinMin: number
  leadTimeHistogramBinMax: number
  leadTimeRangeMonth: number
  leadTimeMinMonth: number
  leadTimeMaxMonth: number
  histogramRange: number
  interquartileRange: number
  leadTimeP25: number
  leadTimeP75: number
}
