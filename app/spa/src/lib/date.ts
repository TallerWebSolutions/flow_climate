import {
  format as dateFnsFormat,
  formatDuration,
  intervalToDuration,
  parseISO,
  secondsToMilliseconds,
} from "date-fns"
import { ptBR } from "date-fns/locale"

const SECONDS_IN_MINUTES = 60
const HOURS_IN_ONE_DAY = 24
const ONE_HOUR_IN_SECONDS = 60 * 60
const ONE_DAY_IN_SECONDS = ONE_HOUR_IN_SECONDS * HOURS_IN_ONE_DAY

export const secondsToReadbleDate = (
  seconds: number,
  separator = " e ",
  dateFormat = ["days", "hours"]
) => {
  if (!seconds || seconds <= 0) return "0 segundos"

  const secondsIntoInterger = parseInt(seconds.toString())
  const msDuration = intervalToDuration({
    start: 0,
    end: secondsToMilliseconds(secondsIntoInterger),
  })

  if (secondsIntoInterger < ONE_DAY_IN_SECONDS) {
    dateFormat.push("minutes")
  }

  if (secondsIntoInterger <= SECONDS_IN_MINUTES) {
    dateFormat.push("seconds")
  }

  return formatDuration(msDuration, {
    format: dateFormat,
    locale: ptBR,
    delimiter: separator,
  })
}

type FormatDateProps = {
  date: string
  format?: string
}

export const formatDate = ({
  date,
  format = "MM/dd/yy",
}: FormatDateProps): string => {
  if (!date.length) return ""
  return dateFnsFormat(parseISO(date), format)
}

export const toISOFormat = (date: string): string => {
  return new Date(date).toISOString()
}

export const secondsToDays = (seconds?: number | string): number => {
  return Number((Number(seconds || 0) / ONE_DAY_IN_SECONDS).toFixed(2))
}

export const secondsToHours = (seconds: number | string): string => {
  const h = Math.floor(Number(seconds) / 3600)
  const m = Math.floor(Number(seconds) % (3600 / 60))

  const hourDisplay = h > 0 ? h + (h === 1 ? " hora" : " horas") : h + " horas"
  const minDisplay = m + " min"

  return `${hourDisplay} e ${minDisplay}`
}
