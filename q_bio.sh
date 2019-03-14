#!/bin/bash

# Variables
PROJECT='tellic-dev'
BUCKET_NAME='tellic-dev'
TELLIC_DIR='tellic-arxiv/pdf'
PROCESSED_FILES='processed_files.txt'
TAR_TXT='### PROCESSED_TAR ###'
PDF_TXT='### PROCESSED_PDF ###'

create_process_file() {
  if ! [ -f ${PROCESSED_FILES} ]; then
    echo "INFO - Creating Process File ${PROCESSED_FILES}"
    touch ${PROCESSED_FILES}
    echo  ${TAR_TXT} > ${PROCESSED_FILES}
    echo  ${PDF_TXT} >> ${PROCESSED_FILES}
  else
    processed_files_content=$(cat ${PROCESSED_FILES})
  fi
}

extract_tar() {

  tar_file_name=$(echo "${tar_file}" | awk -F "/" '{print $NF}')
  if ! [[ "${processed_files_content}" =~ "${tar_file_name}" ]]; then
    echo "INFO - extracting tar file ${tar_file_name}"
    tmp_dir=$(mktemp -d)
    echo "Extracting file: ${tar_file}"
    gsutil cp ${tar_file} ${tmp_dir}
    sed -i "/${TAR_TXT}/a ${tar_file_name}" ${PROCESSED_FILES}
    tar xvf ${tmp_dir}/${tar_file_name} -C ${tmp_dir}
  else
    echo "INFO - Tar File ${tar_file_name} already processed"
  fi
}


# Read PDF
read_pdf() {

  # Create a list of pdf files
  pdf_file_list=$(find ${tmp_dir} -name "*.pdf")
  for pdf_file in ${pdf_file_list}
  do
    pdf_file_name=$(echo "${pdf_file}" | awk -F "/" '{print $NF}')

    # If the pdf file has not be processed process it
    if ! [[ "${processed_files_content}" =~ "${pdf_file_name}" ]]; then
      echo "INFO - Processing ${pdf_file_name}"
      text=$(python pdf2text.py ${pdf_file})

      # Check for q-bio string in PDF file
      lower_text=$(echo "$text" | awk '{print tolower($0)}')
      if [[ ${lower_text} =~ "q-bio" || ${lower_text} =~ "q bio" ]]; then
        echo "INFO - ${pdf_file_name} has q bio content"
        echo -e "==== TAR_FILE:\n ${tar_file_name}\n ==== PDF_FILE:\n ${pdf_file_name}\n ==== BODY:\n ${text}" >> Q-BIO-TEXT.txt
        echo -e "==== TAR_FILE:\n ${tar_file_name}\n ==== PDF_FILE:\n ${pdf_file_name}\n" >> Q-BIO-FILES.txt
      fi

    else
      echo "INFO - PDF File ${pdf_file_name} already processed"
    fi

    echo "INFO - Processing complete ${pdf_file_name}"
    sed -i "/${PDF_TXT}/a ${pdf_file_name}" ${PROCESSED_FILES}
    exit
  done
}


main() {
# Get a list of files
  tar_file_list=$(gsutil ls gs://${BUCKET_NAME}/${TELLIC_DIR})
  create_process_file

  for tar_file in ${tar_file_list}
  do
    extract_tar
    read_pdf
  done
}

main
