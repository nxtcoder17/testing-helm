apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: {{.Values.apps.infraApi.name}}
  namespace: {{.Release.Namespace}}
  annotations:
    kloudlite.io/account-ref: {{.Values.accountName}}
spec:
  region: {{.Values.region}}
  serviceAccount: {{.Values.clusterSvcAccount}}
  services:
    - port: 80
      targetPort: 3000
      name: http
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.infraApi.image}}
      imagePullPolicy: {{.Values.apps.infraApi.ImagePullPolicy | default .Values.imagePullPolicy }}
      
      resourceCpu:
        min: "50m"
        max: "50m"
      resourceMemory:
        min: "50Mi"
        max: "50Mi"

      env:
        - key: FINANCE_GRPC_ADDR
          value: http://{{.Values.apps.financeApi.name}}:3001

        - key: INFRA_DB_NAME
          value: {{.Values.managedResources.infraDb}}

        - key: INFRA_DB_URI
          type: secret
          refName: "mres-{{.Values.managedResources.infraDb}}"
          refKey: URI

        - key: HTTP_PORT
          value: "3000"

        - key: COOKIE_DOMAIN
          value: "{{.Values.cookieDomain}}"

        - key: AUTH_REDIS_HOSTS
          type: secret
          refName: "mres-{{.Values.managedResources.authRedis}}"
          refKey: HOSTS

        - key: AUTH_REDIS_PASSWORD
          type: secret
          refName: "mres-{{.Values.managedResources.authRedis}}"
          refKey: PASSWORD

        - key: AUTH_REDIS_PREFIX
          type: secret
          refName: "mres-{{.Values.managedResources.authRedis}}"
          refKey: PREFIX

        - key: AUTH_REDIS_USER_NAME
          type: secret
          refName: "mres-{{.Values.managedResources.authRedis}}"
          refKey: USERNAME

        - key: KAFKA_BROKERS
          type: secret
          refName: {{.Values.secrets.names.redpandaAdminAuthSecret}}
          refKey: KAFKA_BROKERS

        - key: KAFKA_USERNAME
          type: secret
          refName: {{.Values.secrets.names.redpandaAdminAuthSecret}}
          refKey: USERNAME

        - key: KAFKA_PASSWORD
          type: secret
          refName: {{.Values.secrets.names.redpandaAdminAuthSecret}}
          refKey: PASSWORD

        - key: KAFKA_TOPIC_INFRA_UPDATES
          value: {{.Values.kafka.topicInfraStatusUpdates}}

        - key: KAFKA_CONSUMER_GROUP_ID
          value: {{.Values.kafka.consumerGroupId}}