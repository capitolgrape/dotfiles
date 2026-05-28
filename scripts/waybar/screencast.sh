#!/usr/bin/env bash

set -euo pipefail

readonly SHARE_INFO_SEPARATOR=$'\034'

get_share_client() {
    pw-dump 2>/dev/null | jq -r --arg sep "$SHARE_INFO_SEPARATOR" '
        (
            first(
                .[]
                | select(.type == "PipeWire:Interface:Node")
                | select(.info.props["media.class"] == "Stream/Input/Video")
                | .info.props["client.id"] // empty
            ) // empty
        ) as $client_id
        | first(
            .[]
            | select(.type == "PipeWire:Interface:Client")
            | select(
                (.id | tostring) == ($client_id | tostring)
                or (.info.props["object.id"] | tostring) == ($client_id | tostring)
            )
            | .info.props
            | [
                ."application.process.id",
                ."pipewire.access.portal.app_id",
                ."application.name",
                ."application.process.binary"
            ]
            | map(. // "" | tostring)
            | join($sep)
        ) // empty
    '
}

share_info() {
    local pid app_id app_name binary address class title workspace

    IFS="$SHARE_INFO_SEPARATOR" read -r pid app_id app_name binary < <(get_share_client) || return 1
    [[ -n "$pid$app_id$app_name$binary" ]] || return 1

    IFS=$'\t' read -r address class title workspace < <(
        hyprctl clients -j 2>/dev/null | jq -r \
            --arg pid "$pid" \
            --arg app_id "$app_id" \
            --arg app_name "$app_name" \
            --arg binary "$binary" '
            def row:
                [.address, .class, .title, (.workspace.name // (.workspace.id | tostring))]
                | @tsv;

            def lower($value):
                ($value // "" | tostring | ascii_downcase);

            def identity:
                [$app_id, $app_name, $binary] | map(lower(.)) | join(" ");

            def tokens:
                if (identity | test("discord|vesktop")) then ["discord", "vesktop"]
                elif (identity | test("helium")) then ["helium"]
                elif (identity | test("obs")) then ["obs", "com.obsproject.studio"]
                elif (identity | test("firefox")) then ["firefox"]
                elif (identity | test("chromium")) then ["chromium"]
                elif (identity | test("zoom")) then ["zoom"]
                else [] end;

            def token_match:
                . as $client
                | (tokens) as $tokens
                | ($tokens | length) > 0
                    and any(
                        $tokens[];
                        . as $token
                        | (lower($client.class) | contains($token))
                            or (lower($client.title) | contains($token))
                    );

            (([.[] | select((.pid | tostring) == $pid)] | first)
                // ([.[] | select(token_match)] | first)
                // empty)
            | row
        '
    ) || true

    printf '%s%s%s%s%s\n' "$address" "$SHARE_INFO_SEPARATOR" "$workspace" "$SHARE_INFO_SEPARATOR" "$(friendly_name "$class" "$title" "$app_id" "$app_name" "$binary")"
}

friendly_name() {
    local class=${1,,} title=${2,,} app_id=${3,,} app_name=${4,,} binary=${5,,}

    case "$app_id" in
        *discord* | *vesktop*) printf 'Discord'; return ;;
        *helium*) printf 'Helium Browser'; return ;;
        *obs*) printf 'OBS'; return ;;
        *firefox*) printf 'Firefox'; return ;;
        *chromium*) printf 'Chromium'; return ;;
        *zoom*) printf 'Zoom'; return ;;
    esac

    case "$class" in
        vesktop | discord | *discord*) printf 'Discord'; return ;;
        helium | *helium*) printf 'Helium Browser'; return ;;
        obs | com.obsproject.studio | *obs*) printf 'OBS'; return ;;
        firefox | *firefox*) printf 'Firefox'; return ;;
        chromium | *chromium*) printf 'Chromium'; return ;;
        zoom | *zoom*) printf 'Zoom'; return ;;
    esac

    case "$title" in
        *discord*) printf 'Discord'; return ;;
        *helium*) printf 'Helium Browser'; return ;;
        *obs*) printf 'OBS'; return ;;
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
    local _ name

    if ! IFS="$SHARE_INFO_SEPARATOR" read -r _ _ name < <(share_info) || [[ -z "$name" ]]; then
        jq -cn '{text:"", tooltip:"", class:"inactive"}'
        return
    fi

    jq -cn --arg text $'\uf108' --arg tooltip "Sharing $name" '{text:$text, tooltip:$tooltip, class:"active"}'
}

focus() {
    local _ address workspace active_address cursor_x cursor_y eval_script

    IFS="$SHARE_INFO_SEPARATOR" read -r address workspace _ < <(share_info) || return 0
    [[ -n "$address" && "$address" != "null" ]] || return 0
    active_address=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty' 2>/dev/null || true)
    [[ "$active_address" == "$address" ]] && return 0

    IFS=$'\t' read -r cursor_x cursor_y < <(hyprctl cursorpos -j 2>/dev/null | jq -r '[.x, .y] | @tsv' 2>/dev/null || true) || true

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
