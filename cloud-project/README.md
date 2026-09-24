
# Projet Cloud - Déploiement de ressources AWS avec Floci et Terraform

## 1. Introduction

Ce projet a été réalisé dans le cadre de l'évaluation Cloud, Floci et Terraform.

L'objectif est de mettre en place une infrastructure Cloud locale à l'aide de Terraform en utilisant Floci comme environnement AWS local. Deux services AWS ont été déployés, vérifiés via Floci UI puis supprimés avec Terraform.

Les objectifs atteints sont les suivants :

- Installation et configuration de Floci ;
- Installation et configuration de Floci UI ;
- Sélection d'un Cloud Provider ;
- Déploiement de deux services Cloud avec Terraform ;
- Utilisation de variables Terraform ;
- Utilisation de terraform.tfvars ;
- Utilisation de locals ;
- Utilisation d'outputs ;
- Création de modules réutilisables ;
- Vérification des ressources dans Floci UI ;
- Suppression des ressources avec Terraform.

---

# 2. Choix du Provider

Le provider retenu est :

**AWS**

AWS a été choisi car il est nativement supporté par Floci et permet de déployer localement un grand nombre de services cloud sans avoir besoin d'un compte AWS réel.

Floci expose son environnement AWS local sur :

```text
http://localhost:4566
```

Terraform communique donc avec Floci au lieu de communiquer avec les serveurs AWS réels.

---

# 3. Services choisis

## 3.1 Amazon S3

Amazon S3 est un service de stockage objet permettant de stocker des fichiers et des données dans des buckets.

Dans ce projet, un bucket S3 a été créé :

```text
cloud-project-dev-bucket
```

---

## 3.2 Amazon DynamoDB

Amazon DynamoDB est une base de données NoSQL orientée clé-valeur.

Dans ce projet, une table DynamoDB a été créée :

```text
cloud-project-dev-table
```

---

# 4. Pourquoi ces services ont été choisis

Amazon S3 et Amazon DynamoDB ont été choisis pour plusieurs raisons :

- ils représentent deux catégories importantes de services cloud ;
- ils sont compatibles avec Floci ;
- ils sont simples à déployer avec Terraform ;
- ils permettent de démontrer l'utilisation des modules Terraform ;
- ils permettent d'illustrer l'utilisation simultanée d'un service de stockage et d'une base de données.

---

# 5. Installation et lancement de Floci

## Création du fichier docker-compose.yml

```yaml
services:
  floci:
    image: floci/floci
    container_name: floci
    ports:
      - "4566:4566"
    volumes:
      - "//var/run/docker.sock:/var/run/docker.sock"
```

---

## Démarrage de Floci

```powershell
docker compose up -d
```

---

## Vérification du démarrage

```powershell
docker ps
```

---

## Vérification du runtime AWS local

```powershell
curl http://localhost:4566/_floci/health
```

Le résultat doit contenir notamment :

```json
"s3":"running"
"dynamodb":"running"
```

---

# 6. Installation et lancement de Floci UI

Floci UI permet d'afficher graphiquement les ressources déployées.

---

## Création du réseau Docker

```powershell
docker network create floci-net
```

```powershell
docker network connect floci-net floci
```

---

## Création du fichier docker-compose-ui.yml

```yaml
services:
  floci-ui:
    image: floci/floci-ui
    container_name: floci-ui
    ports:
      - "4500:4500"
    environment:
      - FLOCI_ENDPOINT=http://floci:4566
    networks:
      - floci-net

networks:
  floci-net:
    external: true
```

---

## Démarrage de Floci UI

```powershell
docker compose -f docker-compose-ui.yml up -d
```

---

## Accès à l'interface

```text
http://localhost:4500
```

Lorsque tout fonctionne correctement, l'écran d'accueil affiche :

```text
Connected
Runtime reachable
AWS Local Runtime
```

---

# 7. Structure du projet Terraform

```text
cloud-project/
│
├── main.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars
│
├── modules/
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── dynamodb/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── screenshots/
```

---

# 8. Configuration Terraform

## Provider AWS

Terraform est configuré pour communiquer avec Floci :

```hcl
provider "aws" {
  region     = var.aws_region
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  s3_use_path_style = true

  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
  }
}
```

---

# 9. Variables Terraform

Variables utilisées :

```hcl
project_name
environment
aws_region
dynamodb_hash_key
```

---

## Validation avancée

```hcl
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "L'environnement doit être dev ou prod."
  }
}
```

Cette validation empêche l'utilisation d'environnements non autorisés.

---

# 10. Utilisation de terraform.tfvars

```hcl
project_name      = "cloud-project"
environment       = "dev"
aws_region        = "us-east-1"
dynamodb_hash_key = "id"
```

---

# 11. Utilisation des locals

```hcl
locals {
  resource_prefix = "${var.project_name}-${var.environment}"
}
```

Résultat :

```text
cloud-project-dev
```

---

# 12. Modules Terraform

## Module S3

Le module S3 est responsable de la création du bucket.

Entrées :

```hcl
bucket_name
```

Sorties :

```hcl
bucket_name
```

---

## Module DynamoDB

Le module DynamoDB est responsable de la création de la table.

Entrées :

```hcl
table_name
hash_key
```

Sorties :

```hcl
table_name
```

---

# 13. Gestion des environnements

Le projet supporte plusieurs environnements via la variable :

```hcl
environment
```

## Environnement DEV

```text
cloud-project-dev-bucket
cloud-project-dev-table
```

## Environnement PROD

```text
cloud-project-prod-bucket
cloud-project-prod-table
```

---

# 14. Déploiement Terraform

## Initialisation

```powershell
terraform init
```

---

## Validation

```powershell
terraform validate
```

---

## Planification

```powershell
terraform plan
```

---

## Création des ressources

```powershell
terraform apply
```

Répondre :

```text
yes
```

Résultat obtenu :

```text
bucket_name = cloud-project-dev-bucket
dynamodb_table_name = cloud-project-dev-table
```

---

# 15. Vérification dans Floci UI

Après le déploiement :

## Storage

Vérifier la présence du bucket :

```text
cloud-project-dev-bucket
```

---

## DynamoDB

Vérifier la présence de la table :

```text
cloud-project-dev-table
```

La table doit apparaître avec le statut :

```text
ACTIVE
```

---

# 16. Suppression des ressources

Exécuter :

```powershell
terraform destroy
```

Répondre :

```text
yes
```

Après la suppression, actualiser l'interface Floci UI afin de vérifier la disparition des ressources.

---

# 17. Captures d'écran

Le dossier screenshots contient :

```text
floci.png
floci-ui.png
resources-storage.png
resources-dynamodb.png
destroy.png
```

Ces captures permettent de montrer :

- le bon fonctionnement de Floci ;
- le bon fonctionnement de Floci UI ;
- la création du bucket S3 ;
- la création de la table DynamoDB ;
- la suppression des ressources.

---

# 18. Conclusion

Ce projet a permis de mettre en œuvre Terraform dans un environnement AWS local grâce à Floci.

Les services Amazon S3 et Amazon DynamoDB ont été déployés avec succès à travers une architecture utilisant :

- des variables ;
- des validations Terraform ;
- un fichier terraform.tfvars ;
- des locals ;
- des outputs ;
- des modules réutilisables.

Les ressources ont été vérifiées dans Floci UI puis supprimées correctement avec Terraform.

Cette solution répond aux exigences du projet et respecte les bonnes pratiques de structuration d'une infrastructure Terraform.
