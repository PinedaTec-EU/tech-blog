version: "3.11"
id: "01JV8N4QH0P4JX8S4ZV8R9A102"
name: "concurrent-user-latency-probe"
description: |
  Simulates concurrent users through a checkout business path and makes latency
  spikes visible in the execution report. Validated against Sphere Integration
  Hub v1.7.20.278.
output: false
references:
  workflows:
    - name: "checkout-user"
      path: "./checkout-user.workflow"

input:
  - name: "virtualUsers"
    type: "Array"
    required: true

stages:
  - name: "simulate-checkouts"
    kind: "Workflow"
    workflowRef: "checkout-user"
    forEach: "{{input.virtualUsers}}"
    itemName: "virtualUser"
    indexName: "virtualUserIndex"
    inputs:
      userId: "{{context:virtualUser.userId}}"
      cartId: "{{context:virtualUser.cartId}}"
      sku: "{{context:virtualUser.sku}}"
      quantity: "{{context:virtualUser.quantity}}"
      unitPrice: "{{context:virtualUser.unitPrice}}"
    mock:
      output:
        foreach_count: 12
        foreach_success_count: 12
        foreach_failed_count: 0
        foreach_items: |
          [
            {
              "userId": "user-01",
              "cartId": "cart-01",
              "reservationId": "inv-user-01",
              "quoteId": "price-user-01",
              "checkoutId": "chk-user-01",
              "approved": true,
              "totalAmount": 103.95,
              "inventoryDelayMs": 96,
              "pricingDelayMs": 184,
              "checkoutDelayMs": 214,
              "spike": false,
              "bottleneck": "none"
            }
          ]
