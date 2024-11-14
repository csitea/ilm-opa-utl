# 
cd /opt/ilm/ilm-opa/ilm-opa-utl

# where is the shared drive 
https://drive.google.com/drive/folders/1gGIhHryyyWl6DlmEphTka1QSEAyPOBc9


# how-to start the ansible 
docker exec -it con-ilm-opa-tf-runner bash /opt/ilm/ilm-opa/ilm-opa-inf/src/bash/scripts/run-ansible-ilm-opa-dev-130-org-app-gcp-vm.sh

# how-to start building the infra 
ORG=ilm APP=opa make do-setup-app-inf


# how-to ssh to tst
ssh -o IdentitiesOnly=yes -i ~/.ssh/.str/ilm-opa-tst-wpb.pk debian@tst.opa.ilmatarbrain.com

# how-to ssh to dev
ssh -o IdentitiesOnly=yes -i ~/.ssh/.str/ilm-opa-dev-wpb.pk debian@dev.opa.ilmatarbrain.com


# re-provision 
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=dev ; make -C ../ilm-opa-utl/ do-divest
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=dev ; make -C ../ilm-opa-utl/ do-provision


# how-to backup to gdrive 
rclone -v --progress copy ~/.ssh gdrive:/backups.$(date "+%Y-%m-%d_%H:%M")/.ssh --drive-root-folder-id=1VTEUKpWnL95PrecXAMUOwIsWFcZd1AaS --drive-service-account-file=/home/ysg/.gcp/.csi/ysg-utl-all-e245dd4b59e4.json


rclone -v --progress copy ~/.ssh gdrive:/backups.$(date "+%Y-%m-%d_%H:%M")/.ssh --drive-root-folder-id=1VTEUKpWnL95PrecXAMUOwIsWFcZd1AaS --drive-service-account-file=/home/ysg/.gcp/.csi/ysg-utl-all-e245dd4b59e4.json



SRC_PATH=/opt/flk/flk-doc/flk-doc-rdb TGT_ORG=ilm TGT_APP=opa ./run -a do_replicate_proj_to_tgt_proj;

SRC_DIRS="/opt/ilm/ilm-opa/ilm-opa-rdb/src/sql/mysql/wordpress_db/ddl/" INCLUDE_FILE_GLOB='*.sql' COMMENT="--" EXCLUDE_REGEX='*.tfstate' ./run -a do_cat_files_for_ai
