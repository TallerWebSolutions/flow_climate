import i18n from "i18next"
import { initReactI18next } from "react-i18next"
import resourcesToBackend from "i18next-resources-to-backend"

i18n
  .use(
    resourcesToBackend((language?: string, namespace?: string, callback?: any) => {
      import(`../locales/${language}/${namespace}.json`)
        .then((resources) => {
          callback(null, resources)
        })
        .catch((error) => {
          callback(error, null)
        })
    })
  )
  .use(initReactI18next)
  .init({
    lng: "pt",
    fallbackLng: "en",
    initImmediate: false,
    react: {
      useSuspense: false,
    },
    interpolation: {
      escapeValue: false,
    },
  })

export const loadLanguage = (language: string | undefined) => {
  i18n.changeLanguage(language)
}

export default i18n
