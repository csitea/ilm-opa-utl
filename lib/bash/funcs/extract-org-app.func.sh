# Define the function

# # Call the function
# ORG_APP="ilm-opa"
# do_extract_org_app "$ORG_APP"
# quit_on "extracting " 

do_extract_org_app() {
  local org_app="$1"  # Take the input as the first argument

  # Check if the string contains a hyphen
  if [[ "$org_app" != *-* ]]; then
    echo "Error: The string does not contain a hyphen."
    return 1  # Return with error status
  fi

  # Split the string into ORG and APP
  local org="${org_app%%-*}"  # Extract the part before the hyphen
  local app="${org_app##*-}"  # Extract the part after the hyphen

  # Export the variables to make them available outside the function
  export ORG="$org"
  export APP="$app"

  return 0  # Return with success status
}
