version: "3.11"
id: "01JV8N4QH0P4JX8S4ZV8R9A101"
name: "checkout-user"
description: |
  Runs a single user checkout path across inventory, pricing, and checkout
  services. Validated against Sphere Integration Hub v1.7.20.278.
output: true
references:
  apis:
    - name: "inventory-service"
      definition: "inventory-service"
    - name: "pricing-service"
      definition: "pricing-service"
    - name: "checkout-service"
      definition: "checkout-service"

input:
  - name: "userId"
    type: "Text"
    required: true
  - name: "cartId"
    type: "Text"
    required: true
  - name: "sku"
    type: "Text"
    required: true
  - name: "quantity"
    type: "Number"
    required: true
  - name: "unitPrice"
    type: "Number"
    required: true

stages:
  - name: "reserve-inventory"
    kind: "Endpoint"
    apiRef: "inventory-service"
    endpoint: "/api/reservations"
    httpVerb: "POST"
    expectedStatus: 200
    body: |
      {
        "userId": "{{input.userId}}",
        "sku": "{{input.sku}}",
        "quantity": {{input.quantity}}
      }
    mock:
      status: 200
      payload: |
        {
          "reservationId": "inv-{{input.userId}}",
          "sku": "{{input.sku}}",
          "quantity": {{input.quantity}},
          "reserved": true,
          "simulatedDelayMs": 96,
          "service": "inventory-service"
        }
    output:
      reservationId: "{{response.body.reservationId}}"
      reserved: "{{response.body.reserved}}"
      simulatedDelayMs: "{{response.body.simulatedDelayMs}}"

  - name: "calculate-quote"
    kind: "Endpoint"
    apiRef: "pricing-service"
    endpoint: "/api/quotes"
    httpVerb: "POST"
    expectedStatus: 200
    body: |
      {
        "userId": "{{input.userId}}",
        "sku": "{{input.sku}}",
        "quantity": {{input.quantity}},
        "unitPrice": {{input.unitPrice}}
      }
    mock:
      status: 200
      payload: |
        {
          "quoteId": "price-{{input.userId}}",
          "userId": "{{input.userId}}",
          "currency": "EUR",
          "subtotal": {{input.quantity}},
          "taxes": 4.95,
          "totalAmount": 103.95,
          "simulatedDelayMs": 184,
          "service": "pricing-service"
        }
    output:
      quoteId: "{{response.body.quoteId}}"
      totalAmount: "{{response.body.totalAmount}}"
      simulatedDelayMs: "{{response.body.simulatedDelayMs}}"

  - name: "authorize-checkout"
    kind: "Endpoint"
    apiRef: "checkout-service"
    endpoint: "/api/authorizations"
    httpVerb: "POST"
    expectedStatus: 200
    body: |
      {
        "userId": "{{input.userId}}",
        "cartId": "{{input.cartId}}",
        "quoteId": "{{stage:calculate-quote.output.quoteId}}",
        "totalAmount": {{stage:calculate-quote.output.totalAmount}}
      }
    mock:
      status: 200
      payload: |
        {
          "checkoutId": "chk-{{input.userId}}",
          "userId": "{{input.userId}}",
          "approved": true,
          "totalAmount": 103.95,
          "simulatedDelayMs": 214,
          "spike": false,
          "bottleneck": "none",
          "service": "checkout-service"
        }
    output:
      checkoutId: "{{response.body.checkoutId}}"
      approved: "{{response.body.approved}}"
      totalAmount: "{{response.body.totalAmount}}"
      simulatedDelayMs: "{{response.body.simulatedDelayMs}}"
      spike: "{{response.body.spike}}"
      bottleneck: "{{response.body.bottleneck}}"

endStage:
  output:
    userId: "{{input.userId}}"
    cartId: "{{input.cartId}}"
    reservationId: "{{stage:reserve-inventory.output.reservationId}}"
    quoteId: "{{stage:calculate-quote.output.quoteId}}"
    checkoutId: "{{stage:authorize-checkout.output.checkoutId}}"
    approved: "{{stage:authorize-checkout.output.approved}}"
    totalAmount: "{{stage:authorize-checkout.output.totalAmount}}"
    inventoryDelayMs: "{{stage:reserve-inventory.output.simulatedDelayMs}}"
    pricingDelayMs: "{{stage:calculate-quote.output.simulatedDelayMs}}"
    checkoutDelayMs: "{{stage:authorize-checkout.output.simulatedDelayMs}}"
    spike: "{{stage:authorize-checkout.output.spike}}"
    bottleneck: "{{stage:authorize-checkout.output.bottleneck}}"
