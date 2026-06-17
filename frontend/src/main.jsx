// src/main.jsx
import 'bootstrap/dist/css/bootstrap.min.css'; //← Bootstrapはindex.cssより上
import './index.css';

import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.jsx';

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
);

