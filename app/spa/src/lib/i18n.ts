import i18n from "i18next"
import { initReactI18next } from "react-i18next"

i18n.use(initReactI18next).init({
  resources: {
    en: {
      translation: {
        userMenu: {
          myAccount: "My Account",
          turnOnNotifications: "Turn on Notifications",
          adminDashboard: "Admin Dashboard",
          logout: "Log Out",
        },
      },
    },
    pt: {
      translation: {
        userMenu: {
          myAccount: "Minha Conta",
          turnOnNotifications: "Ligar Notificações",
          adminDashboard: "Painel do Admin",
          logout: "Sair",
        },
      },
    },
  },
  lng: "pt",
  fallbackLng: "pt",
  interpolation: {
    escapeValue: false,
  },
})

export const t = i18n.t
