{{- define "mychart.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}

{{- define "mychart.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}



metadata:
  name: nginx-release-mychart
  labels:
    app.kubernetes.io/name: mychart
    app.kubernetes.io/instance: nginx-release
    app.kubernetes.io/version: 1.0.0


apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{ include "mychart.labels" . | nindent 4 }}











