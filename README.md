# Infrastructure Web AWS avec Terraform

Ce dépôt contient les fichiers de configuration Terraform nécessaires pour déployer une infrastructure web sur AWS pour le TP2 "Déployer une infrastructure Web avec terraform".

## Prérequis

- AWS CLI installé et configuré avec vos identifiants AWS.
- Terraform installé sur votre machine locale.

## Configuration initiale

1. **AWS CLI Configuration**:

   Exécutez la commande suivante et entrez vos clés d'accès, la région (`eu-west-1`) et le format de sortie désiré (`json`).

   ```bash
   aws configure
Clonage du dépôt:

Clonez ce dépôt sur votre machine locale en utilisant Git.

bash
Copy code
git clone https://github.com/votre-username/your-repo-name.git
cd your-repo-name
Déploiement des ressources AWS
Suivez ces étapes pour déployer votre infrastructure :

Initialisation de Terraform:

Initialisez Terraform pour télécharger les plugins nécessaires.

bash
Copy code
terraform init
Création d'un plan de déploiement:

Créez un plan de déploiement Terraform pour visualiser les changements qui seront appliqués.

bash
Copy code
terraform plan
Application de la configuration:

Appliquez la configuration pour créer les ressources dans AWS.

bash
Copy code
terraform apply
Vous devrez confirmer l'application en saisissant yes lorsque vous y êtes invité.

Ressources déployées
Bucket S3:

Un bucket S3 nommé ynov-infracloud-nomprénom pour stocker les images.
Le fichier puppy.jpg est téléchargé dans le bucket.
L'accès public est configuré pour permettre la récupération des objets.
Security Groups:

Un groupe de sécurité pour les serveurs web autorisant le trafic HTTP et SSH.
Un groupe de sécurité pour la base de données autorisant le trafic depuis les instances EC2.
Launch Template:

Un modèle de lancement pour les instances EC2 avec une image AMI spécifique, un type d'instance et des configurations réseau.
Auto Scaling Group:

Un groupe d'Auto Scaling configuré pour lancer automatiquement des instances basées sur le modèle de lancement.
Load Balancer:

Un Load Balancer applicatif configuré pour équilibrer la charge sur les instances EC2.
Listener et Target Group:

Un listener configuré sur le port 80 pour le Load Balancer.
Un groupe cible lié au groupe d'Auto Scaling pour les instances EC2.
Après l'application de la configuration, vous pouvez accéder à l'adresse DNS du Load Balancer pour voir votre application en action.

Nettoyage
Pour supprimer les ressources déployées, exécutez la commande suivante :

bash
Copy code
terraform destroy
Vous devrez confirmer la suppression en saisissant yes lorsque vous y êtes invité.
