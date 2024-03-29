{{- $chartOpts := .Values.grafana }}
{{- if $chartOpts.enabled }}

apiVersion: crds.kloudlite.io/v1
kind: HelmChart
metadata:
  name: {{$chartOpts.name}}
  namespace: {{.Release.Namespace}}
spec:
  chartRepoURL: https://charts.bitnami.com/bitnami
  chartName: grafana
  chartVersion: 9.6.2

  values:
    global:
      storageClass: {{.Values.persistence.storageClasses.ext4}}

    nameOverride: {{$chartOpts.name}}
    fullnameOverride: {{$chartOpts.name}}

    grafana:
      replicaCount: 1
      nodeSelector: {{$chartOpts.configuration.nodeSelector | toJson }}
      priorityClassName: {{.Values.global.statefulPriorityClassName}}

      resources:
        limits:
          cpu: 300m
          memory: 300Mi
        requests:
          cpu: 200m
          memory: 200Mi

    persistence:
      enabled: true
      size: {{$chartOpts.configuration.volumeSize}}

{{- end }}

