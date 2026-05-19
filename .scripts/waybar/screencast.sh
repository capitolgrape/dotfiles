#!/usr/bin/env bash

set -euo pipefail

get_share_client() {
    local dump client_id

    dump=$(pw-dump 2>/dev/null) || return 1
    client_id=$(jq -r '
        .[]
        | select(.type == "PipeWire:Interface:Node")
        | select(.info.props["media.class"] == "Stream/Input/Video")
        | .info.props["client.id"] // empty
    ' <<<"$dump" | head -n 1)

    [[ -n "$client_id" ]] || return 1

    jq -r --arg client_id "$client_id" '
        .[]
        | select(.type == "PipeWire:Interface:Client")
        | select((.id | tostring) == $client_id or (.info.props["object.id"] | tostring) == $client_id)
        | .info.props
        | [
            ."application.process.id",
            ."pipewire.access.portal.app_id",
            ."application.name",
            ."application.process.binary"
        ]
        | @tsv
    ' <<<"$dump" | head -n 1
}

share_info() {
    local client_data pid app_id app_name binary window_data address class title workspace name

    client_data=$(get_share_client) || return 1

    [[ -n "$client_data" ]] || return 1

    IFS=$'\t' read -r pid app_id app_name binary <<<"$client_data"
    window_data=$(hyprctl clients -j 2>/dev/null | jq -r --arg pid "$pid" '
        .[]
        | select((.pid | tostring) == $pid)
        | [.address, .class, .title, (.workspace.name // (.workspace.id | tostring))]
        | @tsv
    ' | head -n 1)

    IFS=$'\t' read -r address class title workspace <<<"$window_data"
    name=$(friendly_name "$class" "$title" "$app_id" "$app_name" "$binary")
    printf '%s\t%s\t%s\n' "$address" "$workspace" "$name"
}

friendly_name() {
    local class=${1,,} title=${2,,} app_id=${3,,} app_name=${4,,} binary=${5,,}

    case "$class" in
        vesktop | discord | *discord*) printf 'Discord'; return ;;
        obs | com.obsproject.studio | *obs*) printf 'OBS'; return ;;
        firefox | *firefox*) printf 'Firefox'; return ;;
        chromium | *chromium*) printf 'Chromium'; return ;;
        google-chrome | *chrome*) printf 'Chrome'; return ;;
        brave-browser | *brave*) printf 'Brave'; return ;;
        zoom | *zoom*) printf 'Zoom'; return ;;
    esac

    case "$title" in
        *discord*) printf 'Discord'; return ;;
        *obs*) printf 'OBS'; return ;;
    esac

    case "$app_id" in
        *discord* | *vesktop*) printf 'Discord'; return ;;
        *obs*) printf 'OBS'; return ;;
        *firefox*) printf 'Firefox'; return ;;
        *chromium*) printf 'Chromium'; return ;;
        *chrome*) printf 'Chrome'; return ;;
        *brave*) printf 'Brave'; return ;;
        *zoom*) printf 'Zoom'; return ;;
    esac

    if [[ -n "$app_name" && "$app_name" != "null" ]]; then
        printf '%s' "$app_name"
    elif [[ -n "$binary" && "$binary" != "null" ]]; then
        printf '%s' "$binary"
    else
        printf 'application'
    fi
}

status() {
    local address workspace name

    if ! IFS=$'\t' read -r address workspace name < <(share_info) || [[ -z "$name" ]]; then
        jq -cn '{text:"", tooltip:"", class:"inactive"}'
        return
    fi

    jq -cn --arg text $'\uf108' --arg tooltip "Sharing $name" '{text:$text, tooltip:$tooltip, class:"active"}'
}

focus() {
    local address workspace name active_address cursor_pos cursor_x cursor_y eval_script

    IFS=$'\t' read -r address workspace name < <(share_info) || return 0
    [[ -n "$address" && "$address" != "null" ]] || return 0
    active_address=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty' 2>/dev/null || true)
    [[ "$active_address" == "$address" ]] && return 0

    cursor_pos=$(hyprctl cursorpos -j 2>/dev/null | jq -r '[.x, .y] | @tsv' 2>/dev/null || true)
    IFS=$'\t' read -r cursor_x cursor_y <<<"$cursor_pos"

    eval_script=""
    if [[ -n "$workspace" && "$workspace" != "null" ]]; then
        eval_script+="hl.dispatch(hl.dsp.focus({ workspace = \"$workspace\" }))
"
    fi

    eval_script+="hl.dispatch(hl.dsp.focus({ window = \"address:$address\" }))
"
    if [[ -n "$cursor_x" && -n "$cursor_y" ]]; then
        eval_script+="hl.dispatch(hl.dsp.cursor.move({ x = $cursor_x, y = $cursor_y }))
"
    fi

    hyprctl eval "$eval_script" >/dev/null 2>&1 || true
}

case "${1:-status}" in
    focus) focus ;;
    status) status ;;
    *) status ;;
esac
