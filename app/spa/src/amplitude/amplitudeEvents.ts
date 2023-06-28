import * as amplitude from '@amplitude/analytics-browser';

amplitude.init('a760159d283dcdb619d596057889137f', 'user', {
  flushQueueSize: 30, // flush queued events when there are 30 or more
  flushIntervalMillis: 10000, // flush queued events every 1 seconds
  useBatch: true, //use batch mode with batch API endpoint, `https://api2.amplitude.com/batch`
  minIdLength: 1,
  serverUrl: 'https://api2.amplitude.com/2/httpapi',
  serverZone: 'US'

});

export const trackPageView = (pageName: string, userId: string, userData: object): any => {
  amplitude.logEvent('Acesso à Página', {
    'Nome da Página': pageName,
    'ID do Usuário': userId,
    'Dados do Usuário': userData,
  });
};

export const setUserId = (userId: string): any => {
  amplitude.setUserId(userId);
};

export const trackEvent = (eventName: string, userId: string, userData: object, company: string): any => {
  amplitude.logEvent(eventName, {
    'ID do Usuário': userId,
    'Dados do Usuário': userData,
    'Empresa Cliente': company,
  });
};

export const trackPageAccess = (pageTitle: string): any => {
  amplitude.logEvent('Acesso à Página', {
    'Título': pageTitle,
  });
};





