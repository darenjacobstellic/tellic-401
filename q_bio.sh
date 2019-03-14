#!/bin/bash

# Variables
PROJECT='tellic-dev'
BUCKET_NAME='tellic-dev'
TELLIC_DIR='tellic-arxiv/pdf'
PROCESSED_FILES='processed_files.txt'

create_process_file() {

  if ! [ -f ${processed_files} ]; then
    touch ${processed_files}
  fi
  echo "***PROCESSED_PDFS"
  echo "***PROCESSED_TARS"

}

extract_tar()
{
  # get tar file
  tmp_dir=$(mktemp -d)
  echo "Extracting file: ${file}"
  gsutil cp ${file} ${tmp_dir}
  exit
}


# Read PDF
read_pdf() {

  if [ "${file}" =~ ${processed_files} ]; then
    echo "File ${file} already processed"
  fi

  text=$(pdf2text.py ${file})
  if ["q-bio" =~ ${text}]; then
    echo ${text} >> ${file}\t${text}
    echo "${file}\n" >> q-bio_files.txt
  fi
}

# Get a list of files
file_list=$(gsutil ls gs://${BUCKET_NAME}/${TELLIC_DIR})

for file in ${file_list}
do
  extract_tar
done
