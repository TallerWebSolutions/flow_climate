import * as amplitude from '@amplitude/analytics-browser';


amplitude.init('a760159d283dcdb619d596057889137f', 'user', {
  flushQueueSize: 30,
  flushIntervalMillis: 10000,
  useBatch: true, //use batch mode with batch API endpoint, `https://api2.amplitude.com/batch`
  minIdLength: 1,
  serverUrl: 'https://api2.amplitude.com/2/httpapi',
  serverZone: 'US'

});

export const trackPageView = (pageName: string, userId: string, userData: object): any => {
  amplitude.logEvent('Usuário', {
    'Nome da Página': pageName,
    'ID do Usuário': userId,
    'Dados do Usuário': userData,
  });
};

export const trackPageAccess = (pageTitle: string): any => {
  amplitude.logEvent('Página Acessada', {
    'Título': pageTitle,
  });
};






export function logEvent(arg0: string, arg1: { teamId: string; device_id: string; }) {
  throw new Error("Function not implemented.");
}

