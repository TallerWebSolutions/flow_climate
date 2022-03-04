import { Dinero, dinero } from "dinero.js"
import { BRL, Currency } from "@dinero.js/currencies"

type CurrencyProps = {
  amount: number
  currency?: Currency<number>
  scale?: number
}

export const currencyFromFloat = ({ amount, currency = BRL, scale = 2 }: CurrencyProps): Dinero<number> => {
  const factor = currency.base ** currency.exponent || scale
  const amountRounded = Math.round(amount * factor)

  return dinero({ amount: amountRounded, currency, scale })
}
