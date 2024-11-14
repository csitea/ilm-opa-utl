#!/bin/bash
do_morph_path() {
  set -x
  do_require_var STR_TO_SRCH "$STR_TO_SRCH"
  do_require_var STR_TO_REPL "$STR_TO_REPL"
  do_require_var TGT_PATH "$TGT_PATH"

  EXCLUDE_FILE="${PROJ_PATH}/cnf/lst/${PROJ}.exclude.lst"

  # Initialize exclude patterns for find command
  declare -a EXCLUDE_PATTERNS=()
  if [ -f "$EXCLUDE_FILE" ]; then
    while IFS= read -r line; do
      # Omit lines that start with a '#' or contain only whitespace characters
      if [[ ! $line =~ ^\s*$ ]] && [[ ! $line =~ ^\s*# ]]; then
        EXCLUDE_PATTERNS+=(-not -path "*$line*")
      fi
    done < <(grep -Ev "^\s*$|^\s*#" "$EXCLUDE_FILE")
  fi

  EXCLUDE_PATTERNS+=(-not -path "*.git*")
  EXCLUDE_PATTERNS+=(-not -path "*node_modules*")
  EXCLUDE_PATTERNS+=(-not -path "*.venv*")

  # For sed, replace STR_TO_SRCH with STR_TO_REPL, excluding directories
  find "$TGT_PATH" "${EXCLUDE_PATTERNS[@]}" -type f -exec sed -i '' -e "s/${STR_TO_SRCH}/${STR_TO_REPL}/g" {} +

  # For renaming, replace STR_TO_SRCH with STR_TO_REPL, excluding directories
  find "$TGT_PATH" "${EXCLUDE_PATTERNS[@]}" -depth -name "*${STR_TO_SRCH}*" -execdir bash -c 'for file; do mv -- "$file" "${file//'$STR_TO_SRCH'/'$STR_TO_REPL'}"; done' bash {} +

  export EXIT_CODE=$?
}
