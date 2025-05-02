resource "grafana_message_template" "discord_template" {
  name     = "Discord Alerts"
  template = <<EOT
{{/*
================================================================================
Discord-Optimized Grafana Alert Template (v5 - Fixed Key/Value Access)
================================================================================
Purpose: Formats Grafana alerts for improved readability in Discord messages
using Markdown. Fixes issue where label/annotation keys showed as numbers.

Key Features:
- Status Emojis: 🚨 for Firing, ✅ for Resolved.
- Markdown: Bold, code ticks, lists, links.
- Clear Sections: Headings for Firing/Resolved alerts.
- Detailed Alert Info: Includes values, labels, annotations, and links.
- Corrected list indentation for Discord.
- Corrected Go template syntax for conditional link separators.
- Corrected access to Label/Annotation Name and Value from SortedPairs.
================================================================================
*/}}

{{/* Define helper for formatting metric values */}}
{{ define "__discord_values_list" -}}
  {{- if len .Values -}}
    {{- $first := true -}}
    {{- range $refID, $value := .Values -}}
      {{- if $first }}{{ $first = false }}{{ else }}, {{ end -}}
      {{- printf "`%s`=`%s`" $refID $value -}}
    {{- end -}}
  {{- else -}}
    `[no value]`
  {{- end -}}
{{- end }}

{{/* Define helper for formatting a list of alerts (firing or resolved) */}}
{{ define "__discord_alert_list" }}
  {{- range $index, $alert := . }}
    {{/* Add a separator line between alerts if this isn't the first one */}}
    {{- if gt $index 0 }}
---
    {{- end }}

    {{/* Display Alert Summary/Name if available in annotations */}}
    {{- if $alert.Annotations.summary }}
      **{{ $alert.Annotations.summary }}**
    {{- else if $alert.Annotations.message }}
      **{{ $alert.Annotations.message | printf "%.100s" }}** {{/* Truncate long messages */}}
    {{- else if $alert.Labels.alertname }}
      **Alert:** `{{ $alert.Labels.alertname }}`
    {{- end }}

    **Value:** {{ template "__discord_values_list" $alert }}

    {{/* Labels Section - CORRECTED Key/Value Access */}}
    {{- if len $alert.Labels }}
**Labels:**
{{- range $index, $pair := $alert.Labels.SortedPairs }} {{/* Get index and the pair object */}}
- `{{ $pair.Name }}` = `{{ $pair.Value }}` {{/* Use .Name and .Value from the pair */}}
{{- end }}
    {{- end }}

    {{/* Annotations Section - CORRECTED Key/Value Access */}}
    {{- if len $alert.Annotations }}
**Annotations:**
{{- range $index, $pair := $alert.Annotations.SortedPairs }} {{/* Get index and the pair object */}}
- **{{ $pair.Name }}:** {{/* Use .Name from the pair */}}
  > {{ $pair.Value }} {{/* Use .Value from the pair */}}
{{- end }}
    {{- end }}

        {{/* Links Section */}}
    {{- if or $alert.GeneratorURL $alert.DashboardURL $alert.PanelURL }}
**Links:** {{- /* Add links on one line, separated by | */}}
      {{- if $alert.GeneratorURL }} [Source]({{ $alert.GeneratorURL }}){{ end -}}
      {{- if $alert.DashboardURL }} {{ if $alert.GeneratorURL }}|{{ end }} [Dashboard]({{ $alert.DashboardURL }}){{ end -}}
      {{- if $alert.PanelURL }} {{ if or $alert.GeneratorURL .DashboardURL }}|{{ end }} [Panel]({{ $alert.PanelURL }}){{ end -}}
    {{- end }}

  {{- end -}} {{/* End range $index, $alert := . */}}
{{- end -}} {{/* End define "__discord_alert_list" */}}


{{/* ==================== Main Template Definitions ==================== */}}

{{/* Define the Title (often used as the first line or embed title) */}}
{{ define "discord.title" -}}
{{/* Status Emoji and Text */}}
{{- if eq .Status "firing" }}🚨 **FIRING**{{ else }}✅ **RESOLVED**{{ end }}
{{- /* Add counts */}}
 [{{- if eq .Status "firing" -}}
    {{- printf "%d firing" (len .Alerts.Firing) -}}
    {{- if gt (len .Alerts.Resolved) 0 }}, {{ printf "%d resolved" (len .Alerts.Resolved) }}{{ end -}}
 {{- else -}}
    {{- printf "%d resolved" (len .Alerts.Resolved) -}}
 {{- end -}}
 ]
{{- /* Primary Grouping Label (e.g., alertname or cluster) */}}
{{- if .GroupLabels.alertname -}} - `{{ .GroupLabels.alertname }}`{{- else -}} - {{ .GroupLabels.SortedPairs.Values | join " " }}{{- end -}}
{{/* Add other common labels if they exist */}}
{{- $common := .CommonLabels.Remove .GroupLabels.Names -}}
{{- if gt (len $common) 0 -}} ({{- range $k, $v := $common -}}`{{$k}}={{$v}}` {{- end -}}){{- end -}}
{{- end -}}

{{/* Define the main Message Body */}}
{{ define "discord.message" -}}
{{/* Section for Firing Alerts */}}
{{- if gt (len .Alerts.Firing) 0 }}
## <a:peepoAlert:1367804942638776423> Firing Alerts ({{ len .Alerts.Firing }})
{{ template "__discord_alert_list" .Alerts.Firing }}
{{- end -}}

{{/* Add a newline separator if both Firing and Resolved alerts are present */}}
{{- if and (gt (len .Alerts.Firing) 0) (gt (len .Alerts.Resolved) 0) }}

{{- end -}}

{{/* Section for Resolved Alerts */}}
{{- if gt (len .Alerts.Resolved) 0 }}
## <a:Saved:1367808344127180882> Resolved Alerts ({{ len .Alerts.Resolved }})
{{ template "__discord_alert_list" .Alerts.Resolved }}
{{- end -}}
{{- end -}} {{/* End define "discord.message" */}}
EOT
}
