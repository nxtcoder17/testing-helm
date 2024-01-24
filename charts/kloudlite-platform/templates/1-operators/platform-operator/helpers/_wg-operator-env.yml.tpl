{{- define "wg-operator-env" -}}
- name: MAX_CONCURRENT_RECONCILES
  value: "5"

- name: CLUSTER_POD_CIDR
  value: {{.Values.operators.wgOperator.configuration.podCIDR}}

- name: CLUSTER_SVC_CIDR
  value: {{.Values.operators.wgOperator.configuration.svcCIDR}}

- name: DNS_HOSTED_ZONE
  value: {{.Values.operators.wgOperator.configuration.dnsHostedZone}}

- name: CLUSTER_INTERNAL_DNS
  value: {{.Values.global.clusterInternalDNS}}
{{- end -}}
