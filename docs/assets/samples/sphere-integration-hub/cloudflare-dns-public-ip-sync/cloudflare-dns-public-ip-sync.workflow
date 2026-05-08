version: "3.11"
id: "01JLCLOUDFLAREDNSIP000001"
name: "cloudflare-dns-public-ip-sync"
description: |
  Discovers the public IP address visible from the running infrastructure, then
  updates JSON-defined Cloudflare DNS records. A records use the discovered
  public IP; static records such as CNAME and TXT use content from the JSON file.
  Validated against Sphere Integration Hub v1.7.20.278.
output: true
references:
  apis:
    - name: "public-ip"
      definition: "public-ip"
    - name: "cloudflare"
      definition: "cloudflare"

input:
  - name: "cloudflareApiToken"
    type: "Text"
    required: true
    secret: true

stages:
  - name: "discover-public-ip"
    kind: "Endpoint"
    apiRef: "public-ip"
    endpoint: "/automation/n09230945.asp"
    httpVerb: "GET"
    expectedStatus: 200
    mock:
      status: 200
      payload: "\"203.0.113.42\""
    output:
      publicIp: "{{response.body}}"
    message: "Infrastructure public IP discovered."

  - name: "update-cloudflare-a-records"
    kind: "Endpoint"
    apiRef: "cloudflare"
    endpoint: "/client/v4/zones/{{context:record.zoneId}}/dns_records/{{context:record.recordId}}"
    httpVerb: "PATCH"
    expectedStatus: 200
    dataFile: "./dns-records.json"
    forEach: "aRecords"
    itemName: "record"
    indexName: "recordIndex"
    headers:
      Content-Type: "application/json"
      Authorization: "Bearer {{input.cloudflareApiToken}}"
    body: |
      {
        "type": "A",
        "name": "{{context:record.name}}",
        "content": "{{stage:discover-public-ip.output.publicIp}}",
        "ttl": {{context:record.ttl}},
        "proxied": {{context:record.proxied}},
        "comment": "Updated by Sphere Integration Hub public IP sync"
      }
    mock:
      status: 200
      payload: |
        {
          "success": true,
          "result": {
            "id": "{{context:record.recordId}}",
            "zone_id": "{{context:record.zoneId}}",
            "type": "A",
            "name": "{{context:record.name}}",
            "content": "{{stage:discover-public-ip.output.publicIp}}",
            "ttl": {{context:record.ttl}},
            "proxied": {{context:record.proxied}}
          }
        }
    output:
      name: "{{context:record.name}}"
      recordId: "{{context:record.recordId}}"
      zoneId: "{{context:record.zoneId}}"
      content: "{{response.body.result.content}}"
      proxied: "{{response.body.result.proxied}}"
      success: "{{response.body.success}}"
      foreach_items: "[]"
    message: "Cloudflare A record {{context:record.name}} updated."

  - name: "update-cloudflare-static-records"
    kind: "Endpoint"
    apiRef: "cloudflare"
    endpoint: "/client/v4/zones/{{context:record.zoneId}}/dns_records/{{context:record.recordId}}"
    httpVerb: "PATCH"
    expectedStatus: 200
    dataFile: "./dns-records.json"
    forEach: "staticRecords"
    itemName: "record"
    indexName: "recordIndex"
    headers:
      Content-Type: "application/json"
      Authorization: "Bearer {{input.cloudflareApiToken}}"
    body: |
      {
        "type": "{{context:record.type}}",
        "name": "{{context:record.name}}",
        "content": "{{context:record.content}}",
        "ttl": {{context:record.ttl}},
        "proxied": {{context:record.proxied}},
        "comment": "Updated by Sphere Integration Hub DNS sync"
      }
    mock:
      status: 200
      payload: |
        {
          "success": true,
          "result": {
            "id": "{{context:record.recordId}}",
            "zone_id": "{{context:record.zoneId}}",
            "type": "{{context:record.type}}",
            "name": "{{context:record.name}}",
            "content": "{{context:record.content}}",
            "ttl": {{context:record.ttl}},
            "proxied": {{context:record.proxied}}
          }
        }
    output:
      type: "{{response.body.result.type}}"
      name: "{{context:record.name}}"
      recordId: "{{context:record.recordId}}"
      zoneId: "{{context:record.zoneId}}"
      content: "{{response.body.result.content}}"
      proxied: "{{response.body.result.proxied}}"
      success: "{{response.body.success}}"
      foreach_items: "[]"
    message: "Cloudflare {{context:record.type}} record {{context:record.name}} updated."

endStage:
  output:
    publicIp: "{{stage:discover-public-ip.output.publicIp}}"
    updatedARecords: "{{stage:update-cloudflare-a-records.output.foreach_items}}"
    updatedStaticRecords: "{{stage:update-cloudflare-static-records.output.foreach_items}}"
