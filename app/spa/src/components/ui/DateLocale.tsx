import { Typography } from "@mui/material"
import { useTranslation } from "react-i18next"

import { formatDate } from "../../lib/date"

type DateLocaleProps = {
  date: string
  time: boolean
}

const DateLocale = ({ date, time }: DateLocaleProps) => {
  const { i18n } = useTranslation()
  const isPtBr = i18n.language === "pt"
  const dateFormat = isPtBr ? "dd/MM/yyyy" : "MM/dd/yyyy"
  const format = time ? `${dateFormat} H:mm aa` : dateFormat

  return <Typography>{formatDate({ date, format })}</Typography>
}

export default DateLocale
