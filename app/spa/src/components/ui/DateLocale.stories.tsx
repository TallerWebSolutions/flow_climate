import React, { useEffect } from "react"
import { ComponentStory, ComponentMeta } from "@storybook/react"
import { I18nextProvider } from "react-i18next"

import i18n, { loadLanguage } from "../../lib/i18n"
import DateLocale from "./DateLocale"

export default {
  title: "DateLocale",
  component: DateLocale,
} as ComponentMeta<typeof DateLocale>

const simpleDate = "2022-07-31"
const dateWithTime = "2018-08-07T16:02:11-03:00"

export const EN: ComponentStory<typeof DateLocale> = () => {
  useEffect(() => {
    loadLanguage("en")
  })

  return (
    <I18nextProvider i18n={i18n}>
      <h2>Simple Date ({simpleDate})</h2>
      <DateLocale date={simpleDate} />

      <h2>Date With Time ({dateWithTime})</h2>
      <DateLocale time date={dateWithTime} />
    </I18nextProvider>
  )
}

export const PTBR: ComponentStory<typeof DateLocale> = () => {
  useEffect(() => {
    loadLanguage("pt")
  })

  return (
    <I18nextProvider i18n={i18n}>
      <h2>Simple Date ({simpleDate})</h2>
      <DateLocale date={simpleDate} />

      <h2>Date With Time ({dateWithTime})</h2>
      <DateLocale time date={dateWithTime} />
    </I18nextProvider>
  )
}
