import {
  formatDuration,
  intervalToDuration,
  secondsToMilliseconds,
} from "date-fns"
import { ptBR } from "date-fns/locale"

export const secondsToReadbleDate = (ms: number) => {
  const msIntoInterger = parseInt(ms.toString())
  const msDuration = intervalToDuration({
    start: 0,
    end: secondsToMilliseconds(msIntoInterger),
  })

  return formatDuration(msDuration, {
    format: ["days", "hours"],
    locale: ptBR,
    delimiter: " e ",
  })
}
