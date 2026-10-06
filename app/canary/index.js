// Synthetics canary: GET /health and POST /orders against the live API.
// Zip layout: nodejs/node_modules/index.js   (handler = "index.handler")
const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const apiUrl = new URL(process.env.API_URL);

// Fails the step unless the status is 2xx
const validateSuccess = async (res) => {
  if (res.statusCode < 200 || res.statusCode > 299) {
    throw new Error(`${res.statusCode} ${res.statusMessage}`);
  }
};

const request = (method, path, body) => ({
  hostname: apiUrl.hostname,
  protocol: 'https:',
  port: 443,
  method,
  path,
  headers: { 'Content-Type': 'application/json', 'User-Agent': synthetics.getCanaryUserAgentString() },
  body: body ? JSON.stringify(body) : undefined,
});

const stepConfig = {
  includeRequestHeaders: true,
  includeResponseHeaders: true,
  includeRequestBody: true,
  includeResponseBody: true,
  continueOnHttpStepFailure: false,
};

exports.handler = async () => {
  synthetics.getConfiguration().setConfig({ restrictedHeaders: [], restrictedUrlParameters: [] });

  await synthetics.executeHttpStep('health', request('GET', '/health'), validateSuccess, stepConfig);
  await synthetics.executeHttpStep('place-order', request('POST', '/orders', { amount: 10, canary: true }), validateSuccess, stepConfig);

  log.info('canary run complete');
};