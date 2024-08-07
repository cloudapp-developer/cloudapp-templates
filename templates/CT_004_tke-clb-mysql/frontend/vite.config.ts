import { defineConfig } from 'vite';
import { resolve, basename } from 'path';
import react from '@vitejs/plugin-react';
import filterReplacePlugin from 'vite-plugin-filter-replace';

const filterReplace = (filterReplacePlugin as any)
  .default as typeof filterReplacePlugin;

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    target: false,
    outDir: resolve(__dirname, '..', '.cloudapp/software/frontend'),
    assetsDir: 'console',
    emptyOutDir: true,
    rollupOptions: {
      external: ['react', 'react-dom'],
      output: {
        globals: {
          react: 'window.cloudapp.lib.React',
          ['react-dom']: 'window.cloudapp.lib.ReactDOM',
        },
        format: 'iife',
        entryFileNames: `console/[name].js`,
        chunkFileNames: `console/[name].js`,
        assetFileNames: (asset) => {
          if (asset.name === 'index.css') {
            return `console/[name].[ext]`;
          }
          return `console/[name].[hash].[ext]`;
        },
      },
    },
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
      },
    },
  },
  experimental: {
    renderBuiltUrl(filename, { hostType }) {
      if (hostType !== 'html') {
        return {
          runtime: `window.cloudapp.toCdnUrl(${JSON.stringify(
            basename(filename)
          )})`,
        };
      }
      return { relative: true };
    },
  },
  plugins: [
    react(),
    filterReplace([
      {
        filter: /\.css$/,
        replace: {
          from: /(\.|=)tea-/g,
          to: '$1cloudapp-',
        },
      },
    ]),
  ],
});
