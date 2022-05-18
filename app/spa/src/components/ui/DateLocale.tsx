import { Typography } from "@mui/material"
import { useTranslation } from "react-i18next"

import { formatDate } from "../../lib/date"

type DateLocaleProps = {
  date: string
  time?: boolean
}

const DateLocale = ({ date, time }: DateLocaleProps) => {
  const { i18n } = useTranslation()
  const isPtBr = i18n.language === "pt"
  const dateFormat = isPtBr ? "dd/MM/yyyy" : "MM/dd/yyyy"
  const format = time ? `${dateFormat} HH:mm` : dateFormat

  return (
    <Typography
      component="span"
      variant="body2"
      sx={{
        minWidth: time ? "115px" : "10px",
      }}
    >
      {formatDate({ date, format })}
    </Typography>
  )
}

export default DateLocale
