#!/bin/bash

do_convert_md_to_pdf() {
  # Ensure pandoc and necessary LaTeX packages are installed
  if ! command -v pandoc &>/dev/null; then
    echo "pandoc not found, installing necessary packages..."
    sudo apt-get update -y
    sudo apt-get install pandoc texlive-latex-base texlive-fonts-recommended texlive-extra-utils texlive-latex-extra -y
  fi

  # take it from the calling shell
  TGT_PROJ_PATH="${TGT_PROJ_PATH:-$PROJ_PATH}"

  # Create output directory if it doesn't exist
  output_dir="$PROJ_PATH/doc/pdf"
  mkdir -p "${output_dir}"

  cd "$TGT_PROJ_PATH/doc/md" || exit
  errors=0
  # Find all markdown files and convert them to PDF
  find "$TGT_PROJ_PATH/doc/md" -name '*.md' | while read -r md_file; do
    # Generate PDF file name
    pdf_file="${output_dir}/$(basename "${md_file%.md}.pdf")"

    # Convert Markdown to PDF with custom margins
    pandoc "$md_file" \
      --toc \
      -V geometry:left=2cm,right=1cm,top=1.5cm,bottom=2cm \
      --pdf-engine=xelatex \
      -o "$pdf_file"

    # Check if conversion was successful
    if [ $? -eq 0 ]; then
      echo "Converted $md_file to $pdf_file"
    else
      echo "Failed to convert $md_file"
      errors=$((errors + 1))
    fi
  done

  echo "All markdown files have been processed."

  export EXIT_CODE=$errors
}
