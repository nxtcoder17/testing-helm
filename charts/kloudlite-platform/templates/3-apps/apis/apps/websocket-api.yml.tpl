apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: websocket-api
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{ .Values.global.clusterSvcAccount }}

  {{ include "node-selector-and-tolerations" . | nindent 2 }}

  services:
    - port: 80
      targetPort: 3000
      name: http
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.websocketApi.image}}
      imagePullPolicy: {{.Values.global.imagePullPolicy }}
      resourceCpu:
        min: "50m"
        max: "80m"
      resourceMemory:
        min: "80Mi"
        max: "120Mi"
      env:
        - key: SOCKET_PORT
          value: "3000"

        - key: IAM_GRPC_ADDR
          value: iam:3001

        - key: SESSION_KV_BUCKET
          value: {{.Values.envVars.nats.buckets.sessionKVBucket.name}}

        - key: NATS_URL
          value: {{.Values.envVars.nats.url}}

        - key: COOKIE_DOMAIN
          value: "{{.Values.global.cookieDomain}}"
