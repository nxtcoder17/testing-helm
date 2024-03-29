apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: comms
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{ .Values.global.clusterSvcAccount }}

  {{ include "node-selector-and-tolerations" . | nindent 2 }}

  services:
    - port: 3001
      targetPort: 3001
      name: grpc
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.commsApi.image}}
      imagePullPolicy: {{.Values.global.imagePullPolicy }}
      {{if .Values.global.isDev}}
      args:
       - --dev
      {{end}}
      resourceCpu:
        min: "50m"
        max: "80m"
      resourceMemory:
        min: "80Mi"
        max: "120Mi"

      env:
        - key: GRPC_PORT
          value: "3001"

        - key: SUPPORT_EMAIL
          value: {{.Values.sendGrid.supportEmail}}

        - key: SENDGRID_API_KEY
          value: {{.Values.sendGrid.apiKey}}

        - key: ACCOUNTS_WEB_INVITE_URL
          value: https://auth.{{ include "router-domain" . }}/invite

        - key: PROJECTS_WEB_INVITE_URL
          value: https://auth.{{ include "router-domain" . }}/invite

        - key: KLOUDLITE_CONSOLE_WEB_URL
          value: https://console.{{include "router-domain" .}}

        - key: RESET_PASSWORD_WEB_URL
          value: https://auth.{{include "router-domain" .}}/reset-password

        - key: VERIFY_EMAIL_WEB_URL
          value: https://auth.{{include "router-domain" . }}/verify-email
        
        {{/* TODO: url should definitely NOT be auth.{{.Values.baseDomain}} */}}
        - key: EMAIL_LINKS_BASE_URL
          value: https://auth.{{include "router-domain" .}}/
