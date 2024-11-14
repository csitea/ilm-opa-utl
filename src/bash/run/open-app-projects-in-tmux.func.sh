do_open_app_projects_in_tmux() {

  # Check if ORG and APP are set in the environment, otherwise extract from PROJ
  if [[ -z "${ORG:-}" || -z "${APP:-}" ]]; then
    ORG=$(echo $PROJ | cut -d'-' -f1)
    APP=$(echo $PROJ | cut -d'-' -f2)
  fi
  local SESSION="sess-$ORG-$APP"
  tmux new-session -d -s $SESSION || {
    echo "Failed to create session"
    exit 1
  }

  # Find dirs and store them in an array
  if test -f $APP_PATH/.tmux/dirs.lst; then
    mapfile -t dirs <"$APP_PATH/.tmux/dirs.lst"
  else
    dirs=($(find "$APP_PATH" -mindepth 1 -maxdepth 1 -type d))
  fi

  # Iterate over dirs and create a window for each
  for dir in "${dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      echo "Error: Directory does not exist - $dir"
      continue
    fi

    local base_name=$(basename "$dir")
    local window_name=$(printf '%.30s' "$base_name    ")

    # Create a new window with the name and change to the directory,
    # capturing the window ID to ensure the correct window is targeted for renaming.
    local window_id=$(tmux new-window -t $SESSION -n "$window_name" -P -F "#{window_id}" "cd \"$dir\" && bash -i") || {
      echo "Failed to create window: $window_name for dir: $dir"
      continue
    }

    # Rename the window using the captured window ID
    tmux rename-window -t "$window_id" "$window_name" || {
      echo "Failed to rename window ID: $window_id to $window_name"
      continue
    }

    echo "Created and renamed window: $window_name (ID: $window_id) for directory: $dir"
  done

  tmux attach -t $SESSION || {
    echo "Failed to attach to session: $SESSION"
    exit 1
  }

  export EXIT_CODE="0"
}
