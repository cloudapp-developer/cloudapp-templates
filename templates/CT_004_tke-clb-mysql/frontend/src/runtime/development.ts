import React from 'react';
import ReactDOM from 'react-dom';
import { GlobalCloudappAPI } from './production';

const cloudapp: GlobalCloudappAPI = {
  mode: 'local',
  lib: {
    React,
    ReactDOM,
  },
  run: (fn) => {
    fn(document.getElementById('root')!);
  },
  callAPI: async (apiName, apiPayload = {}) => {
    const response = await fetch(`/api/${apiName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(apiPayload),
    });
    const json = await response.json();
    return {
      ResponseBody: json,
      ResponseCode: 'success',
      ResponseMessage: 'success',
    };
  },
};

export default cloudapp;
