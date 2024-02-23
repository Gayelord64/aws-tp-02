# Infrastructure Web AWS avec Terraform

Ce dépôt contient la configuration Terraform nécessaire pour déployer une infrastructure web complète sur AWS, conformément aux exigences du TP2 "Déployer une infrastructure Web avec terraform".

## Prérequis

- AWS CLI doit être installé et configuré avec les identifiants d'accès appropriés.
- Terraform doit être installé sur votre machine locale.

## Configuration Initiale

### Configurer AWS CLI

Exécutez la commande suivante pour configurer AWS CLI avec vos clés d'accès et la région par défaut :

```bash
aws configure
```


## Clonage du dépôt:

Clonez ce dépôt sur votre machine locale en utilisant Git.

```bash
git clone https://github.com/votre-username/your-repo-name.git
cd your-repo-name
```

## Déploiement des ressources AWS

### Initialisation de Terraform:

Initialisez Terraform pour télécharger les plugins nécessaires.

```bash
terraform init
```

### Création d'un plan de déploiement:

Créez un plan de déploiement Terraform pour visualiser les changements qui seront appliqués.

```bash
terraform plan
```

### Application de la configuration:

Appliquez la configuration pour créer les ressources dans AWS.

```bash
terraform apply
```
Vous devrez confirmer l'application en saisissant yes lorsque vous y êtes invité.

## Ressources déployées
* __Bucket S3__:
   * Un bucket S3 nommé ynov-infracloud-nomprénom pour stocker les images.
   * Le fichier puppy.jpg est téléchargé dans le bucket.
   * L'accès public est configuré pour permettre la récupération des objets.
* __Security Group__:

   * Un groupe de sécurité pour les serveurs web autorisant le trafic HTTP et SSH.
   * Un groupe de sécurité pour la base de données autorisant le trafic depuis les instances EC2.
* __Launch Template__:

   * Un modèle de lancement pour les instances EC2 avec une image AMI spécifique, un type d'instance et des configurations réseau.
* __Auto Scaling Group__:

   * Un groupe d'Auto Scaling configuré pour lancer automatiquement des instances basées sur le modèle de lancement.
* __Load Balancer__:

   * Un Load Balancer applicatif configuré pour équilibrer la charge sur les instances EC2.
* __Listener et Target Group__:

   * Un listener configuré sur le port 80 pour le Load Balancer.
   * Un groupe cible lié au groupe d'Auto Scaling pour les instances EC2.
     
Après l'application de la configuration, vous pouvez accéder à l'adresse DNS du Load Balancer pour voir votre application en action.
