{{if .Values.operators.nodepoolOperator.enabled}}
{{ $name := .Values.operators.nodepoolOperator.name }}
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: kube-rbac-proxy
    app.kubernetes.io/name: service
    app.kubernetes.io/part-of: {{$name}}
    control-plane: {{$name}}
  name: {{$name}}
  namespace: {{.Release.Namespace}}
spec:
  ports:
    - name: https
      port: 8443
      protocol: TCP
      targetPort: https
  selector:
    control-plane: {{$name}}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{$name}}-cloudflare-params
  namespace: {{.Release.Namespace}}
data:
  api_token: {{.Values.operators.clusterOperator.configuration.cloudflare.apiToken | b64enc | quote }}
  base_domain: {{.Values.operators.clusterOperator.configuration.cloudflare.baseDomain | b64enc | quote }}
  zone_id: {{.Values.operators.clusterOperator.configuration.cloudflare.zoneId | b64enc | quote }}

	{{- /* ReconcilePeriod         time.Duration `env:"RECONCILE_PERIOD"` */}}
	{{- /* MaxConcurrentReconciles int           `env:"MAX_CONCURRENT_RECONCILES"` */}}
	{{- /**/}}
	{{- /* CloudProviderName   string `env:"CLOUD_PROVIDER_NAME" required:"true"` */}}
	{{- /* CloudProviderRegion string `env:"CLOUD_PROVIDER_REGION" required:"true"` */}}
	{{- /**/}}
	{{- /* CloudProviderAccessKey string `env:"CLOUD_PROVIDER_ACCESS_KEY" required:"true"` */}}
	{{- /* CloudProviderSecretKey string `env:"CLOUD_PROVIDER_SECRET_KEY" required:"true"` */}}
	{{- /**/}}
	{{- /* K3sJoinToken        string `env:"K3S_JOIN_TOKEN" required:"true"` */}}
	{{- /* K3sServerPublicHost string `env:"K3S_SERVER_PUBLIC_HOST" required:"true"` */}}
	{{- /**/}}
	{{- /* KloudliteAccountName string `env:"KLOUDLITE_ACCOUNT_NAME" required:"true"` */}}
	{{- /* KloudliteClusterName string `env:"KLOUDLITE_CLUSTER_NAME" required:"true"` */}}
	{{- /**/}}
	{{- /* IACStateS3BucketName           string `env:"IAC_STATE_S3_BUCKET_NAME" required:"true"` */}}
	{{- /* IACStateS3BucketRegion         string `env:"IAC_STATE_S3_BUCKET_REGION" required:"true"` */}}

---

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/component: manager
    app.kubernetes.io/name: deployment
    app.kubernetes.io/part-of: {{$name}}
    control-plane: {{$name}}
  name: {{$name}}
  namespace: {{.Release.Namespace}}
spec:
  replicas: 1
  selector:
    matchLabels: &labels
      control-plane: {{$name}}
  template:
    metadata:
      annotations:
        kubectl.kubernetes.io/default-container: manager
      labels: *labels
    spec:
      affinity:
        {{- if .Values.preferOperatorsOnMasterNodes }}
        {{include "preferred-node-affinity-to-masters" . | nindent 10 }}
        {{- end }}
      containers:
        - args:
            - --secure-listen-address=0.0.0.0:8443
            - --upstream=http://127.0.0.1:8080/
            - --logtostderr=true
            - --v=0
          image: gcr.io/kubebuilder/kube-rbac-proxy:v0.13.0
          name: kube-rbac-proxy
          ports:
            - containerPort: 8443
              name: https
              protocol: TCP
          resources:
            limits:
              cpu: 30m
              memory: 30Mi
            requests:
              cpu: 20m
              memory: 20Mi
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
        - args:
            - --health-probe-bind-address=:8081
            - --metrics-bind-address=127.0.0.1:8080
            - --leader-elect
          command:
            - /manager
          
          env:
            - name: RECONCILE_PERIOD
              value: "30s"
              
            - name: MAX_CONCURRENT_RECONCILES
              value: "5"
            
            - name: CLOUD_PROVIDER_NAME
              value: {{.Values.operators.nodepoolOperator.configuration.cloudprovider.name}}

            - name: CLOUD_PROVIDER_REGION
              value: {{.Values.operators.nodepoolOperator.configuration.cloudprovider.region}}

            - name: CLOUD_PROVIDER_ACCESS_KEY
              value: {{.Values.operators.nodepoolOperator.configuration.cloudprovider.accessKey}}

            - name: CLOUD_PROVIDER_SECRET_KEY
              value: {{.Values.operators.nodepoolOperator.configuration.cloudprovider.secretKey}}

            - name: K3S_JOIN_TOKEN
              value: {{.Values.operators.nodepoolOperator.configuration.k3s.joinToken}}

            - name: K3S_SERVER_PUBLIC_HOST
              value: {{.Values.operators.nodepoolOperator.configuration.k3s.serverPublicHost}}

            - name: IAC_STATE_S3_BUCKET_NAME
              value: {{.Values.operators.nodepoolOperator.configuration.IACStateStore.s3BucketName}}

            - name: IAC_STATE_S3_BUCKET_REGION
              value: {{.Values.operators.nodepoolOperator.configuration.IACStateStore.s3BucketRegion}}

            - name: IAC_STATE_S3_BUCKET_DIR
              value: {{.Values.operators.nodepoolOperator.configuration.IACStateStore.s3BucketDir}}

            - name: KLOUDLITE_ACCOUNT_NAME
              value: {{.Values.accountName}}

            - name: KLOUDLITE_CLUSTER_NAME
              value: "{{.Values.clusterName}}"

          image: {{.Values.operators.nodepoolOperator.image}}
          imagePullPolicy: {{.Values.operators.nodepoolOperator.ImagePullPolicy | default .Values.imagePullPolicy }}
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8081
            initialDelaySeconds: 15
            periodSeconds: 20
          name: manager
          readinessProbe:
            httpGet:
              path: /readyz
              port: 8081
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            limits:
              cpu: 50m
              memory: 50Mi
            requests:
              cpu: 20m
              memory: 20Mi
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
      securityContext:
        runAsNonRoot: true
      serviceAccountName: {{.Values.clusterSvcAccount | squote}}
      terminationGracePeriodSeconds: 10
{{end}}

