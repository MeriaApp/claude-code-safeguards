#!/bin/bash
# Hook: process-screenshot (PreToolUse on Read)
# Intercepts image file reads, resizes, files into project screenshots/, blocks original read.
# Exit 2 = block + stderr shown to Claude as feedback.
# Exit 0 = allow read through (non-image files, already-filed screenshots).
#
# Why: Dropping screenshots into Claude Code can blow past the 20MB request limit,
# crash the session, and leave you stuck with no way to recover. This hook catches
# image reads before they hit the API, resizes retina screenshots, and files them
# into your project for proper reference.

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

[ "$tool_name" != "Read" ] && exit 0

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")
[ -z "$file_path" ] && exit 0

# Allow reads from already-filed screenshots
[[ "$file_path" == */screenshots/* ]] && exit 0

# Check if image by extension
ext="${file_path##*.}"
ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
case "$ext_lower" in
  png|jpg|jpeg|gif|webp|heic|heif|tiff|bmp) ;;
  *) exit 0 ;;
esac

# File must exist
[ ! -f "$file_path" ] && exit 0

# Get file size for reporting
file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")

# Determine project root from hook's cwd field, then git, then pwd
hook_cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null || echo "")
if [ -n "$hook_cwd" ] && [ -d "$hook_cwd" ]; then
  project_root="$hook_cwd"
elif git rev-parse --show-toplevel >/dev/null 2>&1; then
  project_root=$(git rev-parse --show-toplevel)
else
  project_root=$(pwd)
fi

screenshots_dir="${project_root}/screenshots"
mkdir -p "$screenshots_dir"

# Generate unique filename: YYYYMMDD_HHMMSS + collision avoidance
timestamp=$(date +%Y%m%d_%H%M%S)
counter=0
output="${screenshots_dir}/${timestamp}.${ext_lower}"
while [ -f "$output" ]; do
  ((counter++))
  output="${screenshots_dir}/${timestamp}_${counter}.${ext_lower}"
done

# --- macOS: use sips (built-in) ---
if command -v sips >/dev/null 2>&1; then
  if ! sips -g pixelWidth "$file_path" >/dev/null 2>&1; then
    cp "$file_path" "$output" 2>/dev/null || exit 0
    echo "Screenshot filed (format not resizable): ${output}" >&2
    echo "Use an Agent to read and parse the screenshot at: ${output}" >&2
    exit 2
  fi

  current_width=$(sips -g pixelWidth "$file_path" 2>/dev/null | awk '/pixelWidth/ {print $2}')

  if [ -n "$current_width" ] && [ "$current_width" -gt 1400 ] 2>/dev/null; then
    sips --resampleWidth 1400 "$file_path" --out "$output" >/dev/null 2>&1 || cp "$file_path" "$output" 2>/dev/null
  else
    cp "$file_path" "$output" 2>/dev/null
  fi

  final_dims=$(sips -g pixelWidth -g pixelHeight "$output" 2>/dev/null | awk '/pixel/ {print $2}' | tr '\n' 'x' | sed 's/x$//')

# --- Linux: use ImageMagick if available, otherwise just copy ---
elif command -v convert >/dev/null 2>&1; then
  current_width=$(identify -format "%w" "$file_path" 2>/dev/null || echo "0")

  if [ -n "$current_width" ] && [ "$current_width" -gt 1400 ] 2>/dev/null; then
    convert "$file_path" -resize 1400x "$output" 2>/dev/null || cp "$file_path" "$output" 2>/dev/null
  else
    cp "$file_path" "$output" 2>/dev/null
  fi

  final_dims=$(identify -format "%wx%h" "$output" 2>/dev/null || echo "?")

# --- No image tools: just copy ---
else
  cp "$file_path" "$output" 2>/dev/null
  final_dims="unknown"
fi

# Verify output
if [ ! -f "$output" ]; then
  exit 0
fi

# Get final size (macOS stat vs Linux stat)
final_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null || echo "?")

# Cleanup: keep only 50 most recent screenshots (works on macOS + Linux)
ls -t "$screenshots_dir"/* 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null || true

# Block the original read — stderr goes to Claude as feedback
echo "Screenshot filed to: ${output}" >&2
echo "Dimensions: ${final_dims} | Size: ${final_size} bytes (original: ${file_size} bytes)" >&2
echo "" >&2
echo "DO NOT read the original temp file. Use an Agent to read and fully parse the filed screenshot at:" >&2
echo "${output}" >&2
exit 2
