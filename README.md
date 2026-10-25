# 🏛️ Système de Gestion du Laboratoire LIAS

<p align="center">
  <img src="https://img.shields.io/badge/Java-21-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white" alt="Java 21" />
  <img src="https://img.shields.io/badge/Jakarta%20EE-10-F80000?style=for-the-badge&logo=eclipse-ide&logoColor=white" alt="Jakarta EE 10" />
  <img src="https://img.shields.io/badge/Apache%20Tomcat-10.1-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black" alt="Tomcat 10.1" />
  <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL 8.0" />
  <img src="https://img.shields.io/badge/Docker-Enabled-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" />
  <img src="https://img.shields.io/badge/PlantUML-SVG-5A3E85?style=for-the-badge&logo=diagramsdotnet&logoColor=white" alt="PlantUML" />
</p>

<p align="center">
  <b>Projet de Fin de Module — Conception & Développement d'Applications d'Entreprise (JEE)</b><br>
  <b>Master Data Science & Big Data (Promotion 2025–2026)</b><br>
  <i>Faculté des Sciences Ben M'Sik — Université Hassan II de Casablanca</i>
</p>

---

## 📌 Présentation Générale du Projet

L'application **LIAS** est la plateforme officielle de centralisation et de préservation de la **mémoire institutionnelle** du **Laboratoire d'Informatique et Applications Scientifiques**.

Conçue sur la base d'un cahier des charges rigoureux de 8 pages, l'application répond à des problématiques académiques complexes :
1. **Gestion du cycle de vie des membres :** Historisation temporelle sans suppression (*zéro perte de données*), permettant de retracer le parcours complet d'un chercheur (arrivées, départs, retours et changements de grade).
2. **Gouvernance et mandats :** Séparation stricte entre le statut académique permanent d'un professeur et son rôle temporaire de direction ou de chef d'équipe sous un mandat donné.
3. **Production scientifique & Événements :** Répertoire des publications indexées (IEEE, ACM, Springer), organisation des séminaires, workshops et journées scientifiques.
4. **Logistique et équipement :** Arbitrage équitable des demandes de matériel (stations de calcul GPU, laptops, serveurs) par la direction.
5. **Génération du Bilan Annuel :** Calcul automatisé des indicateurs de performance requis par l'université et les organismes subventionnaires (CNRST).

---

## 🏗️ Architecture Logicielle (JEE Classique — MVC 2)

Le système respecte scrupuleusement le patron de conception **Modèle-Vue-Contrôleur 2 (MVC 2)** sans dépendance envers des frameworks opaques (ni Spring, ni Hibernate), garantissant une maîtrise totale des concepts fondateurs de Jakarta EE :

```
                                  ┌─────────────────────────────┐
                                  │      Client (Navigateur)    │
                                  └──────────────┬──────────────┘
                                                 │ Requête HTTP
                                                 ▼
                                  ┌─────────────────────────────┐
                                  │   AuthFilter (Sécurité RBAC)│
                                  └──────────────┬──────────────┘
                                                 │
                                                 ▼
┌─────────────────────────────┐   ┌─────────────────────────────┐   ┌─────────────────────────────┐
│    Couche Présentation      │   │      Couche Contrôleur      │   │        Couche Métier        │
│         (VUES JSP)          │◄──┤    (Jakarta Servlets 6.0)   ├──►│   (Logique d'Entreprise)    │
│  - JSTL Core / Formatting   │   │  - HomeServlet, LoginServlet│   │  - IMetier / MetierImpl     │
│  - Expression Language (EL) │   │  - AdhesionServlet, etc.    │   │  - Calcul des indicateurs   │
│  - AppShell Layout          │   └─────────────────────────────┘   └──────────────┬──────────────┘
└─────────────────────────────┘                                                    │
                                                                                   ▼
                                  ┌─────────────────────────────┐   ┌─────────────────────────────┐
                                  │  Couche Persistance (JDBC)  │   │  Couche Accès Données (DAO) │
                                  │ - DBConnection (Singleton)  │◄──┤  - Contrats IDao / DaoImpl  │
                                  │ - PreparedStatement (MySQL) │   │  - Mapping vers JavaBeans   │
                                  └─────────────────────────────┘   └─────────────────────────────┘
```

### Principes Clés d'Implémentation :
* **Vue (JSP) :** Vues conformes à la règle **Zéro Scriptlet Java**. Utilisation exclusive des balises **JSTL** (`<c:forEach>`, `<c:if>`) et des expressions **EL** (`${member.fullName}`).
* **Contrôleur (Servlet) :** Les Servlets dérivent de `HttpServlet`, extraient les paramètres HTTP, invoquent la couche métier/DAO et transfèrent la vue via `RequestDispatcher.forward()`.
* **Modèle (JavaBeans) :** Objets sérialisables purs respectant la convention JavaBean (constructeur sans argument, propriétés privées et accesseurs `get`/`set`).
* **Accès aux Données (DAO Pattern) :** Découplage strict via des interfaces Java (`IUserDao`, `IMemberDao`, `IPublicationDao`, etc.) et requêtes SQL préparées (`PreparedStatement`) pour bloquer toute tentative d'injection SQL.
* **Connexion Unique (Singleton) :** Classe `DBConnection` à constructeur privé assurant l'unicité et le recyclage de la connexion JDBC MySQL.

---

## 📐 Dossier de Conception & Modélisation UML

Le projet dispose d'une suite documentaire complète et interactive consultable directement dans n'importe quel navigateur web :

| # | Document de Conception | Format | Lien direct | Description |
|---|---|:---:|:---:|---|
| **1** | **Diagrammes de Cas d'Utilisation** | HTML + PlantUML | [Consulter](docs/diagrammes-cas-utilisation.html) | Hiérarchie des acteurs, Macro-diagramme global et 4 sous-systèmes détaillés. |
| **2** | **Diagrammes de Séquence Boîte Noire (DSS)** | HTML + PlantUML | [Consulter](docs/diagrammes-sequence-boite-noire.html) | 6 scénarios de flux système : authentification, adhésion, matériel, recherche, etc. |
| **3** | **Diagrammes de Séquence Boîte Blanche (DSBB)** | HTML + PlantUML | [Consulter](docs/diagrammes-sequence-boite-blanche.html) | Déroulement interne MVC 2 (JSP ⟵ Filter ⟵ Servlet ⟵ Métier ⟵ DAO ⟵ JDBC ⟵ MySQL). |
| **4** | **Diagrammes de Classes UML** | HTML + PlantUML | [Consulter](docs/diagramme-de-classes.html) | Modèle de Domaine Métier (10 entités) & Architecture logicielle MVC 2. |
| **5** | **Dictionnaire de Données Officiel** | HTML Interactif | [Consulter](docs/dictionnaire-de-donnees.html) | 10 tables, 58+ champs, types SQL/Java EE, contraintes, règles CDC et filtre temps réel. |
| **6** | **Catalogue des Interfaces (IHM)** | HTML Interactif | [Consulter](docs/catalogue-des-interfaces.html) | 14 écrans IHM détaillés, sitemap, wireframes, matrice RBAC et traçabilité complète. |
| **7** | **Guide Complet & Préparation Soutenance** | HTML Documenté | [Consulter](docs/guide-complet-projet.html) | Argumentaire technique, points forts académiques et Q&R pour le jury. |

---

## 🗄️ Modèle de Données & Schéma Relationnel MySQL

Le schéma de base de données relationnelle est normalisé en **3NF / BCNF** et implémente le principe d'**historisation temporelle non-destructive** :

```text
USERS (1) ─────────── (0..1) MEMBERS (1) ════════ (1..*) AFFILIATION_PERIODS
                                 │
                                 ├───────────── (0..*) PUBLICATIONS
                                 ├───────────── (0..*) EVENEMENTS
                                 ├───────────── (0..*) MATERIELS
                                 │
DEMANDES_ADHESION               MANDATS (1) ─────────── (0..*) CONVENTIONS
(Acceptation ⟶ Crée Member)     (Présidence)
```

### Comptes de test pré-configurés :
| Rôle Système | Identifiant (Email) | Mot de passe | Droits & Prérogatives |
|---|---|:---:|---|
| **Directeur** | `directeur@lias.ma` | `admin123` | Arbitrage des adhésions, attribution du matériel, validation des bilans. |
| **Membre Permanent** | `permanent@lias.ma` | `pass123` | Dépôt d'articles, proposition d'événements, demande de matériel GPU. |
| **Doctorant** | `doctorant@lias.ma` | `doc123` | Consultation, ajout de publications et demande de matériel. |
| **Administrateur** | `admin@lias.ma` | `admin123` | Gestion technique des comptes, réinitialisation des accès. |

---

## 🚀 Guide de Démarrage & Déploiement

### Option 1 : Déploiement Conteneurisé avec Docker (Recommandé)

Aucune installation locale de Java, Tomcat ou MySQL n'est requise. Un seul script suffit :

```bash
# Cloner le dépôt
git clone https://github.com/ibtissamesadiki/gestion-du-laboratoire-LIAS.git
cd gestion-du-laboratoire-LIAS

# Démarrer l'environnement complet
docker compose up --build
```

* **Application Web :** [http://localhost:8080](http://localhost:8080)
* **Serveur MySQL :** Port `3306` (Base: `lias_db`, Utilisateur: `lias_user`, Mot de passe: `lias_password`)

---

### Option 2 : Importation dans Eclipse IDE

1. Ouvrez **Eclipse IDE for Enterprise Java and Web Developers**.
2. Allez dans : **File** ⟶ **Import...** ⟶ **General** ⟶ **Existing Projects into Workspace**.
3. Sélectionnez le répertoire racine `gestion-du-laboratoire-LIAS`.
4. Importez le schéma SQL dans votre serveur MySQL local :
   ```bash
   mysql -u root -p < schema.sql
   ```
5. Clic droit sur le projet ⟶ **Run As** ⟶ **Run on Server** (sélectionner Apache Tomcat v10.1+).
6. L'application est disponible sur : `http://localhost:8080/gestion_du_laboratoire_LIAS/`.

---

## 📁 Arborescence du Projet

```text
gestion-du-laboratoire-LIAS/
├── .gitignore                         → Exclusions Git (fichiers compilés, caches, logs)
├── .project / .classpath              → Configuration projet Eclipse IDE
├── Dockerfile                         → Conteneur d'exécution Tomcat 10.1 (multi-stage)
├── docker-compose.yml                 → Orchestration des conteneurs App + MySQL 8.0
├── schema.sql                         → Script DDL & DML MySQL (Tables + Seed Data)
├── README.md                          → Documentation technique principale
│
├── src/main/
│   ├── java/com/lias/
│   │   ├── beans/                     → Modèle Métier (User, Member, AffiliationPeriod, Mandat, Convention, ReunionPV, etc.)
│   │   ├── dao/                       → Interfaces & Implémentations DAO (JDBC natif)
│   │   │   ├── DBConnection.java      → Gestionnaire thread-safe de connexions MySQL
│   │   │   ├── IUserDao.java / UserDaoImpl.java
│   │   │   ├── IMemberDao.java / MemberDaoImpl.java (Affiliations & Traçabilité)
│   │   │   ├── IMandatDao.java / MandatDaoImpl.java (Mandats de Direction)
│   │   │   ├── IConventionDao.java / ConventionDaoImpl.java (Partenariats R&D)
│   │   │   ├── IPVDao.java / PVDaoImpl.java (Procès-Verbaux & Délibérations)
│   │   │   └── IPublicationDao.java / PublicationDaoImpl.java
│   │   ├── metier/                    → Couche Logique Métier (IMetier / MetierImpl)
│   │   ├── web/                       → 14 Contrôleurs Servlets (Home, Mandat, Convention, PV, Admin, Adhesion, etc.)
│   │   └── filter/                    → Filtres de sécurité RBAC (AuthFilter)
│   └── webapp/
│       ├── WEB-INF/
│       │   ├── lib/                   → Connecteur JDBC MySQL 8.x
│       │   ├── views/                 → 14 Vues JSP conformes AppShell (home, mandats, conventions, pv, admin...)
│       │   │   └── includes/          → Fragments réutilisables (header, sidebar, quick search modal)
│       │   └── web.xml                → Descripteur de déploiement Jakarta Servlet 6.0
│       ├── css/                       → Feuilles de styles CSS & Design System
│       └── index.jsp                  → Redirection d'entrée vers la Servlet d'accueil
│
└── docs/                              → Suite complète de conception UML & Spécifications
    ├── diagrams/                      → Mégapack des 14 diagrammes vectoriels PlantUML SVG
    ├── diagrammes-cas-utilisation.html
    ├── diagrammes-sequence-boite-noire.html
    ├── diagrammes-sequence-boite-blanche.html
    ├── diagramme-de-classes.html
    ├── dictionnaire-de-donnees.html
    ├── guide-complet-projet.html
    ├── system-design.md
    └── data-model.md
```

---

## 👥 Auteur & Remerciements

* **Réalisé par :** Ibtissam Essadiki
* **Filière :** Master Data Science & Big Data (DS&BD)
* **Établissement :** Faculté des Sciences Ben M'Sik, Casablanca
* **Module :** Conception & Développement d'Applications JEE

---
<p align="center">
  <i>Laboratoire d'Informatique et Applications Scientifiques (LIAS) — Tous droits réservés © 2026</i>
</p>
