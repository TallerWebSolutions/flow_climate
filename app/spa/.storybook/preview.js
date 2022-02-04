export const parameters = {
  actions: { argTypesRegex: "^on[A-Z].*" },
  controls: {
    matchers: {
      color: /(background|color)$/i,
      date: /Date$/,
    },
  },
}

import ThemeProvider from '../src/lib/ThemeProvider'

const withThemeProvider = (Story, context) => {
  return (
    <ThemeProvider>
      <Story {...context} />
    </ThemeProvider>
  );
};

export const decorators = [withThemeProvider];
