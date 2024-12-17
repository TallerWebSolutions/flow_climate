import { ReactElement } from "react"
import {
  createTheme,
  ThemeProvider as MaterialThemeProvider,
} from "@mui/material/styles"
import { GlobalStyles } from "@mui/material"

const theme = createTheme({
  palette: {
    primary: {
      light: "#9674A2",
      main: "#523E57",
      dark: "#29172E",
    },
    secondary: {
      light: "#634C6B",
      main: "#29172E",
      dark: "#140318",
    },
    warning: {
      light: "#FF9C3F",
      main: "#ED6C02",
      dark: "#B33D00",
    },
    success: {
      light: "#80E27E",
      main: "#4CAF50",
      dark: "#087F23",
    },
    grey: {
      200: "#CCCCCC",
      600: "#666666",
    },
    background: {
      paper: "#F5F5FF",
    },
  },
  typography: {
    body1: {
      fontWeight: 400,
      fontSize: "16px",
      lineHeight: 1.5,
      color: "#29172E",
    },
    body2: {
      fontWeight: 400,
      fontSize: ".875rem",
      lineHeight: 1.43,
    },
    h4: {
      color: "#666",
      fontSize: "34px",
      fontStyle: "normal",
      fontWeight: 400,
      lineHeight: "42px",
    },
    h6: {
      color: "primary.main",
      fontSize: "20px",
      fontStyle: "normal",
      fontWeight: 500,
      lineHeight: "32px",
      letterSpacing: "0.12px",
    },
    subtitle1: {
      fontWeight: 500,
      fontSize: "1rem",
      lineHeight: 1.75,
      color: "black",
    },
    subtitle2: {
      fontWeight: 500,
      fontSize: ".875rem",
      lineHeight: 1.57,
      color: "black",
    },
  },
  components: {
    MuiTableCell: {
      styleOverrides: {
        root: {
          borderBottom: "none",
          padding: "8px",
        },
      },
    },
    MuiTableHead: {
      styleOverrides: {
        root: {
          th: {
            fontWeight: "bold",
          },
        },
      },
    },
    MuiButton: {
      variants: [
        {
          props: { variant: "contained" },
          style: { height: "35", textTransform: "uppercase", color: "primary" },
        },
      ],
    },
    MuiLink: {
      defaultProps: {
        variant: "body2",
      },
    },
    MuiCard: {
      defaultProps: {
        variant: "outlined",
      },
      styleOverrides: {
        root: {
          borderRadius: 2,
          border: "1px solid",
        },
      },
    },
  },
})

const ThemeProvider = ({ children }: { children: ReactElement }) => (
  <MaterialThemeProvider theme={theme}>
    <GlobalStyles
      styles={{ body: { padding: 0, margin: 0, fontFamily: "Roboto" } }}
    />
    {children}
  </MaterialThemeProvider>
)

export default ThemeProvider
