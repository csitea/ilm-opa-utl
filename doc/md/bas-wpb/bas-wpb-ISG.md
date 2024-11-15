# ilm-opa INSTALL GUIDE

## Checkout All ilm-opa Projects

```bash
gh api orgs/csitea/teams/team-ilm-opa-int/repos | jq -r '.[].ssh_url' | xargs -L1 git clone
```

## Build the Infrastructure Local Development Setup

Ensure you have checked out all the necessary ilm-opa projects
```bash
make -C ../ilm-opa-utl do-setup-app-inf
``` 


## Step-by-Step Instructions
### Step 000: GCP Remote Bucket

#### STEP=000-gcp-remote-bucket for ilm-opa-dev
```bash
# generate Configuration for dev
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=dev \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```

```bash

# provision for dev
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-provision 
```

```bash

# divest for dev
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-divest 

```

#### STEP=000-gcp-remote-bucket for ilm-opa-tst


```bash
# generate Configuration for tst
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=tst \
TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
;make -C ../ilm-opa-utl do-generate-config-for-step
```

provision for tst
```bash
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-provision 
```

divest for tst

```bash
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-divest 
```

#### STEP=000-gcp-remote-bucket for ilm-opa-prd

Generate Configuration for prd
```bash
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=prd \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```

provision for prd
```bash
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-provision 
``` 

divest for prd
```bash
clear ; export STEP=000-gcp-remote-bucket ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-divest 
```

### Step 008: GCP Subzones

generate Configuration for dev
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=dev \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```
provision for dev
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-provision 
``` 

divest for dev
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-divest 

```
#### STEP=STEP=008-gcp-subzones for ilm-opa-tst

Generate Configuration for tst
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=tst \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```

Provision for tst
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-provision 
```
Divest for tst
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-divest 


```

### Step 008-gcp-subzones for ilm-opa-prd

Generate Configuration for prd:
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=prd \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```

Provision for prd:
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-provision 
```

Divest for prd:
```bash
clear ; export STEP=008-gcp-subzones ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-divest 

```
### Step 015: GCP Remote Bucket

### STEP 015-gcp-remote-bucket fo ilm-opa-dev
Generate Configuration for dev:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=dev \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```
Provision for dev:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-provision 
```

Divest for dev:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-divest 


```

### Step 015-gcp-remote-bucket for ilm-opa-tst

Generate Configuration for tst:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=tst \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```
Provision for tst:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-provision 
```
Divest for tst:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-divest 

```

### Step 015-gcp-remote-bucket for ilm-opa-prd

Generate Configuration for prd:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=prd \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```
Provision for prd:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-provision 
```
Divest for prd:
```bash
clear ; export STEP=015-gcp-remote-bucket ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-divest 

```


###  Step 120: GitHub General Secrets

### Step 120-github-general-secrets for ilm-opa-dev

Generate Configuration for dev:
```bash
clear ; export STEP=120-github-general-secrets ORG=ilm APP=opa ENV=dev \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```
Provision for dev:
```bash
clear ; export STEP=120-github-general-secrets ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-provision 
```

Divest for dev
```bash
clear ; export STEP=120-github-general-secrets ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-divest 
```

### Step 120-github-general-secrets for ilm-opa-tst
Generate Configuration for tst:
```bash
clear ; export STEP=120-github-general-secrets ORG=ilm APP=opa ENV=tst \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```

Provision for tst:
```bash
clear ; export STEP=120-github-general-secrets ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-provision 
```

Divest for tst
```bash
clear ; export STEP=120-github-general-secrets ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-divest 
```

### Step 120-github-general-secrets for ilm-opa-prd
Generate Configuration for prd
```bash
clear ; export STEP=120-github-general-secrets ORG=ilm APP=opa ENV=prd \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step

```

### Step 130: GCP VM

#### Step 130-org-app-gcp-vm for ilm-opa-dev

Generate Configuration for dev:
```bash
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=dev \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf; \
  make -C ../ilm-opa-utl do-generate-config-for-step
``` 

Provision for dev:
```bash

clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-provision 
``` 
Divest for dev:
```bash
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-divest 

```

### Step 130-org-app-gcp-vm for ilm-opa-tst

Generate Configuration for tst:
```bash
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=tst \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
``` 

Provision for tst:
```bash

clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-provision 
``` 
Divest for tst:

```bash
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-divest  

```

### Step 130-org-app-gcp-vm for ilm-opa-prd

Generate Configuration for prd:
```bash
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=prd \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
``` 

Provision for prd:
```bash

clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-provision 
``` 
Divest for prd:

```bash
clear ; export STEP=130-org-app-gcp-vm ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-divest 

```
### Step 131: GCP VM www-data Setup

Generate Configuration for dev
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=dev \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```
Provision for dev
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-provision 
```

Divest for dev
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=dev \
  ;make -C ../ilm-opa-utl do-divest 
```

### Step 001-enable-gcp-services for ilm-opa-tst

generate Configuration for tst
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=tst \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf \
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```

provision for tst
```bash

clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-provision 
```

divest for tst
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=tst \
  ;make -C ../ilm-opa-utl do-divest 
```

### Step 001-enable-gcp-services for ilm-opa-prd

generate Configuration for prd
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=prd \
  TPL_SRC=/opt/ilm/ilm-opa/ilm-opa-inf \
  SRC=/opt/ilm/ilm-opa/ilm-opa-cnf/ \
  TGT=/opt/ilm/ilm-opa/ilm-opa-cnf
  ;make -C ../ilm-opa-utl do-generate-config-for-step
```

provision for prd
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-provision 
```

divest for prd
```bash
clear ; export STEP=001-enable-gcp-services ORG=ilm APP=opa ENV=prd \
  ;make -C ../ilm-opa-utl do-divest 

```
