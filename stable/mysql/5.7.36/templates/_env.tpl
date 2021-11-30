{{/*
Render environment variable
*/}}
{{- define "common.containers.environmentVariable" -}}
{{- $envVariable := . -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "name")) -}}
{{- if $envVariable.valueFromSecret -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "secretName" "secretKey")) -}}
- name: {{ $envVariable.name | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ $envVariable.secretName | quote }}
      key: {{ $envVariable.secretKey | quote }}
{{- else -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "value")) -}}
- name: {{ $envVariable.name | quote }}
  value: {{ $envVariable.value | quote }}
{{- end -}}
{{- end -}}

{{/*
Render environment variables
*/}}
{{- define "common.containers.environmentVariables" -}}
{{- $values := . -}}
{{- include "common.schema.validateKeys" (dict "values" $values "checkKeys" (list "environmentVariables")) -}}
{{- range $envVariable := $values.environmentVariables -}}
{{- include "common.containers.environmentVariable" $envVariable | nindent 0 -}}
{{- end -}}
{{- end -}}

{{/*
Render environment variables if present
*/}}
{{- define "common.containers.allEnvironmentVariables" -}}
{{- $values := . -}}
{{- include "common.schema.validateKeys" (dict "values" $values "checkKeys" (list "environmentVariables")) -}}
{{- if $values.environmentVariables -}}
env: {{- include "common.containers.environmentVariables" $values | nindent 2 -}}
{{- end -}}
{{- end -}}

{{/*
Checks if a list of keys are present in a dictionary
*/}}
{{- define "common.schema.validateKeys" -}}
{{- $values := . -}}
{{- if and (hasKey $values "values") (hasKey $values "checkKeys") -}}
{{- $missingKeys := list -}}
{{- range $values.checkKeys -}}
{{- if eq (hasKey $values.values . ) false -}}
{{- $missingKeys = mustAppend $missingKeys . -}}
{{- end -}}
{{- end -}}
{{- if $missingKeys -}}
{{- fail (printf "Missing %s from dictionary" ($missingKeys | join ", ")) -}}
{{- end -}}
{{- else -}}
{{- fail "A dictionary and list of keys to check must be provided" -}}
{{- end -}}
{{- end -}}
