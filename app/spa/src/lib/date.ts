import {
  formatDuration,
  intervalToDuration,
  secondsToMilliseconds,
} from "date-fns"
import { ptBR } from "date-fns/locale"

const SECONDS_IN_A_DAY = 24 * 60 * 60
const SECONDS_IN_MINUTES = 60

export const secondsToReadbleDate = (seconds: number) => {
  if (!seconds || seconds <= 0) return "0 segundos"

  const secondsIntoInterger = parseInt(seconds.toString())
  const msDuration = intervalToDuration({
    start: 0,
    end: secondsToMilliseconds(secondsIntoInterger),
  })

  var dateFormat = ["days", "hours"]

  if (secondsIntoInterger < SECONDS_IN_A_DAY) {
    dateFormat.push("minutes")
  }

  if (secondsIntoInterger <= SECONDS_IN_MINUTES) {
    dateFormat.push("seconds")
  }

  return formatDuration(msDuration, {
    format: dateFormat,
    locale: ptBR,
    delimiter: " e ",
  })
}
