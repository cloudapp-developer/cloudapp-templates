import type React from 'react';
import type ReactDOM from 'react-dom';

declare global {
  interface Window {
    cloudapp: GlobalCloudappAPI;
  }
}

interface CloudappAPIResult<R = any> {
  ResponseBody: R;
  ResponseCode: string;
  ResponseMessage: string;
}

type DestroyFunction = () => void;

export interface GlobalCloudappAPI {
  /**
   * 应用运行模式
   */
  mode: 'console' | 'local';

  /**
   * 全局包
   */
  lib: {
    React: typeof React;
    ReactDOM: typeof ReactDOM;
  };

  /**
   * 获取文件 CDN URL
   */
  toCdnUrl?: (filename: string) => string;

  /**
   * 运行应用
   */
  run(fn: (container: Element) => DestroyFunction): void;

  /**
   * 调用应用 API
   */
  callAPI<R = any>(
    apiName: string,
    apiPayload?: object
  ): Promise<CloudappAPIResult<R>>;
}

const cloudapp = window.cloudapp;

export default cloudapp;
