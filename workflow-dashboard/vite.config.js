import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      // Forward management API calls to the Ballerina workflow management endpoint.
      '/workflow': 'http://localhost:8234',
    },
  },
});
