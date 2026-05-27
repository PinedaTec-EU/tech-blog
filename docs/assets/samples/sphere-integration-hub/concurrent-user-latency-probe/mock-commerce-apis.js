#!/usr/bin/env node

const http = require("http");

function readJson(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
    });
    req.on("end", () => {
      if (!body) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(body));
      } catch (error) {
        reject(error);
      }
    });
    req.on("error", reject);
  });
}

function jitter(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function writeJson(res, status, payload) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(payload));
}

function createServer({ port, serviceName, handler }) {
  const server = http.createServer(async (req, res) => {
    if (req.method === "GET" && req.url === "/health") {
      writeJson(res, 200, { status: "ok", service: serviceName });
      return;
    }

    if (req.method !== "POST") {
      writeJson(res, 405, { error: "method_not_allowed" });
      return;
    }

    try {
      const payload = await readJson(req);
      const response = await handler(payload);
      writeJson(res, 200, response);
    } catch (error) {
      writeJson(res, 500, {
        error: "unhandled_error",
        message: error instanceof Error ? error.message : String(error)
      });
    }
  });

  server.listen(port, "127.0.0.1", () => {
    console.log(`[${serviceName}] listening on http://127.0.0.1:${port}`);
  });
}

createServer({
  port: 4101,
  serviceName: "inventory-service",
  handler: async (payload) => {
    const simulatedDelayMs = jitter(60, 140);
    await delay(simulatedDelayMs);

    return {
      reservationId: `inv-${payload.userId}`,
      sku: payload.sku,
      quantity: payload.quantity,
      reserved: true,
      simulatedDelayMs,
      service: "inventory-service"
    };
  }
});

createServer({
  port: 4102,
  serviceName: "pricing-service",
  handler: async (payload) => {
    const simulatedDelayMs = jitter(110, 260);
    await delay(simulatedDelayMs);

    return {
      quoteId: `price-${payload.userId}`,
      userId: payload.userId,
      currency: "EUR",
      subtotal: Number(payload.unitPrice) * Number(payload.quantity),
      taxes: 4.95,
      totalAmount: Number((Number(payload.unitPrice) * Number(payload.quantity) + 4.95).toFixed(2)),
      simulatedDelayMs,
      service: "pricing-service"
    };
  }
});

createServer({
  port: 4103,
  serviceName: "checkout-service",
  handler: async (payload) => {
    const baselineDelayMs = jitter(140, 260);
    const spikeDelayMs = payload.userId === "user-07" ? 2200 : 0;
    const simulatedDelayMs = baselineDelayMs + spikeDelayMs;
    await delay(simulatedDelayMs);

    return {
      checkoutId: `chk-${payload.userId}`,
      userId: payload.userId,
      approved: true,
      totalAmount: payload.totalAmount,
      simulatedDelayMs,
      spike: spikeDelayMs > 0,
      bottleneck: spikeDelayMs > 0 ? "warehouse-allocation-lock" : "none",
      service: "checkout-service"
    };
  }
});
