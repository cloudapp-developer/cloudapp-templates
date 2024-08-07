import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import cloudapp from './runtime';

if (cloudapp) {
  cloudapp.run((container) => {
    ReactDOM.render(<App />, container);
    return () => {
      if (container) {
        ReactDOM.unmountComponentAtNode(container);
      }
    };
  });
}
