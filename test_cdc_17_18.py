import requests
import re
import sys

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')

BASE_URL = "http://localhost:8080"

def run_tests():
    s = requests.Session()
    print("=== DÉBUT DES TESTS CDC §17 (PROCÈS-VERBAUX) & §18 (RECHERCHE GLOBALE) ===")

    # 1. Connexion Directeur
    print("\n[1] Connexion en tant que Directeur...")
    res = s.post(f"{BASE_URL}/login", data={
        "email": "directeur@lias.ma",
        "password": "admin123"
    }, allow_redirects=True)
    assert res.status_code == 200, f"Erreur login: {res.status_code}"
    assert "tableau de bord" in res.text.lower() or "espace" in res.text.lower(), "Échec de connexion"
    print("✓ Connexion Directeur réussie (Prof. Ibtissam Essadiki).")

    # 2. Consultation Registre des PV (CDC §17 ⭐)
    print("\n[2] Consultation de la page des Procès-Verbaux (/pv)...")
    res = s.get(f"{BASE_URL}/pv")
    assert res.status_code == 200, f"Erreur /pv: {res.status_code}"
    assert "Procès-Verbaux de Réunions" in res.text, "Titre de page manquant"
    assert "Registre Officiel des Procès-Verbaux" in res.text, "Tableau du registre manquant"
    assert "Total Délibérations" in res.text, "Cartes statistiques manquantes"
    assert "Assemblées Générales" in res.text, "Stat AG manquante"
    assert "Conseils de Laboratoire" in res.text, "Stat CL manquante"
    print("✓ Page /pv accessible avec toutes les métriques et tableaux officiels.")

    # 3. Création d'une Réunion & Ordre du jour (CDC §17 ⭐)
    print("\n[3] Création d'une réunion avec Ordre du Jour détaillé (CDC §17 ⭐)...")
    test_title = f"Conseil Extraordinaire : Répartition Crédits Calcul & Accueil Nouveaux Chercheurs 2026"
    test_odj = "1. Approbation du PV de la séance précédente.\n2. Examen des besoins matériels GPU et serveurs.\n3. Validation des candidatures de post-doctorat.\n4. Calendrier des manifestations scientifiques 2026."
    
    res = s.post(f"{BASE_URL}/pv", data={
        "action": "creer_reunion",
        "titre": test_title,
        "typeReunion": "Conseil Extraordinaire",
        "dateReunion": "2026-06-18",
        "heure": "09:30 - 12:30",
        "lieu": "Salle du Conseil LIAS - FSBM",
        "ordreDuJour": test_odj,
        "directeurSignataire": "Prof. Ibtissam Essadiki",
        "secretaireSeance": "Prof. Mohamed Benali",
        "statut": "PLANIFIEE",
        "cheminFichierPV": "archives/pv_conseil_extra_juin2026.pdf"
    }, allow_redirects=True)
    assert res.status_code == 200, f"Erreur création réunion: {res.status_code}"
    assert test_title in res.text, "La réunion créée n'apparaît pas dans la liste"
    assert "Planifiée" in res.text or "PLANIFIEE" in res.text, "Statut Planifiée manquant"
    print("✓ Réunion et son Ordre du Jour créés et visibles dans le registre.")

    # Extraire l'ID de la réunion créée
    meeting_ids = re.findall(r'action=telecharger&id=(\d+)', res.text)
    assert meeting_ids, "Impossible d'extraire l'ID de la réunion"
    created_id = meeting_ids[0]
    print(f"✓ ID de la réunion créée : {created_id}")

    # 4. Upload du PV et Clôture d'archivage (CDC §17 ⭐)
    print("\n[4] Upload du PV officiel signé et passage en statut Archivé (CDC §17 ⭐)...")
    res = s.post(f"{BASE_URL}/pv", data={
        "action": "upload_pv",
        "reunionId": created_id,
        "nomFichier": "archives/pv_officiel_signe_scelle_juin2026.pdf",
        "statut": "ARCHIVEE"
    }, allow_redirects=True)
    assert res.status_code == 200, f"Erreur upload PV: {res.status_code}"
    assert "Le fichier officiel du Procès-Verbal a été téléversé et archivé" in res.text or "uploaded" in res.url, "Confirmation d'archivage manquante"
    print("✓ PV téléversé et archivé sous statut officiel scellé.")

    # 5. Téléchargement et Consultation du PV officiel en stream (CDC §17 ⭐)
    print("\n[5] Test du téléchargement du document certifié (GET /pv?action=telecharger&id=...)...")
    dl_res = s.get(f"{BASE_URL}/pv?action=telecharger&id={created_id}")
    assert dl_res.status_code == 200, f"Erreur téléchargement: {dl_res.status_code}"
    assert "ROYAUME DU MAROC" in dl_res.text, "En-tête officiel manquant dans le document téléchargé"
    assert "LABORATOIRE D'INFORMATIQUE ET D'AIDE À LA DÉCISION (LIAS)" in dl_res.text, "En-tête LIAS manquant"
    assert "PROCÈS-VERBAL OFFICIEL DE RÉUNION" in dl_res.text, "Titre du PV manquant"
    assert test_title in dl_res.text, "Titre de la séance manquant dans le texte téléchargé"
    assert "Prof. Ibtissam Essadiki" in dl_res.text, "Signature du directeur manquante"
    print("✓ Téléchargement du PV validé avec certificat et mentions statutaires.")

    print("\n[5b] Test de la consultation inline (GET /pv?action=consulter&id=...)...")
    view_res = s.get(f"{BASE_URL}/pv?action=consulter&id={created_id}")
    assert view_res.status_code == 200, f"Erreur consultation inline: {view_res.status_code}"
    assert "inline" in view_res.headers.get("Content-Disposition", ""), "Header inline manquant"
    print("✓ Consultation inline du document validée.")

    # 6. Filtrage du registre (CDC §17 ⭐)
    print("\n[6] Test des filtres par type et par statut...")
    filter_ag = s.get(f"{BASE_URL}/pv?type=Assemblée Générale")
    assert filter_ag.status_code == 200
    assert "Assemblée Générale" in filter_ag.text

    filter_arch = s.get(f"{BASE_URL}/pv?statut=ARCHIVEE")
    assert filter_arch.status_code == 200
    assert "Archivé & Signé" in filter_arch.text
    print("✓ Filtres par type et par statut fonctionnels.")

    # 7. Recherche Globale & Consultation Multi-Entités (CDC §18 ⭐)
    print("\n[7] Test de la Recherche Globale (/recherche - CDC §18 ⭐)...")
    res_rech_home = s.get(f"{BASE_URL}/recherche")
    assert res_rech_home.status_code == 200, f"Erreur /recherche: {res_rech_home.status_code}"
    assert "Recherche Globale & Consultation" in res_rech_home.text
    assert "Membres du Laboratoire" in res_rech_home.text
    assert "Archive Documentaire" in res_rech_home.text
    assert "Événements Scientifiques" in res_rech_home.text
    assert "Publications Indexées" in res_rech_home.text
    print("✓ Page d'accueil /recherche accessible avec les 4 modules institutionnels majeurs.")

    # 7a. Recherche globale transversale mot-clé "Essadiki"
    print("\n[7a] Recherche mot-clé 'Essadiki'...")
    res_q1 = s.get(f"{BASE_URL}/recherche?q=Essadiki")
    assert res_q1.status_code == 200
    assert "Ibtissam" in res_q1.text, "Membre non trouvé dans les résultats"
    assert "Membres (" in res_q1.text, "Onglet Membres manquant"
    assert "Consulter profil complet" in res_q1.text, "Action de consultation profil membre manquante"
    print("✓ Recherche transverse sur les membres validée avec lien de consultation.")

    # 7b. Recherche globale transversale mot-clé "GPU"
    print("\n[7b] Recherche mot-clé 'GPU'...")
    res_q2 = s.get(f"{BASE_URL}/recherche?q=GPU")
    assert res_q2.status_code == 200
    assert "GPU" in res_q2.text
    print("✓ Recherche transverse mot-clé 'GPU' validée.")

    # 7c. Recherche globale transversale mot-clé "Intelligence" (Publications & Événements)
    print("\n[7c] Recherche mot-clé 'Intelligence'...")
    res_q3 = s.get(f"{BASE_URL}/recherche?q=Intelligence")
    assert res_q3.status_code == 200
    assert "Intelligence" in res_q3.text
    assert "Publications" in res_q3.text
    print("✓ Recherche transverse sur publications et événements validée.")

    # 7d. Filtrage par catégorie dans la recherche
    print("\n[7d] Filtrage des résultats par catégorie 'membres'...")
    res_cat_mem = s.get(f"{BASE_URL}/recherche?q=Essadiki&cat=membres")
    assert res_cat_mem.status_code == 200
    assert "Chercheurs & Doctorants du LIAS" in res_cat_mem.text
    print("✓ Onglet catégorie Membres validé.")

    print("\n[7e] Filtrage des résultats par catégorie 'documents'...")
    res_cat_doc = s.get(f"{BASE_URL}/recherche?q=Rapport&cat=documents")
    assert res_cat_doc.status_code == 200
    assert "Archive Documentaire Officielle" in res_cat_doc.text
    print("✓ Onglet catégorie Documents validé.")

    # 8. Test de Contrôle d'Accès CDC §2.2 pour Doctorant
    print("\n[8] Test des autorisations pour un compte Doctorant...")
    s_doc = requests.Session()
    res_doc_login = s_doc.post(f"{BASE_URL}/login", data={
        "email": "doctorant@lias.ma",
        "password": "doc123"
    }, allow_redirects=True)
    assert res_doc_login.status_code == 200
    print("✓ Connexion Doctorant réussie.")

    # Doctorant a le droit de faire une recherche globale (CDC §18)
    res_doc_search = s_doc.get(f"{BASE_URL}/recherche?q=Spark")
    assert res_doc_search.status_code == 200
    assert "Recherche Globale" in res_doc_search.text
    print("✓ Doctorant autorisé à utiliser la Recherche Globale (CDC §18).")

    # Doctorant n'a pas le droit d'accéder aux PV internes de gouvernance (CDC §2.2)
    res_doc_pv = s_doc.get(f"{BASE_URL}/pv")
    assert res_doc_pv.status_code == 403 or "403" in res_doc_pv.text or "Accès Restreint" in res_doc_pv.text, f"Le doctorant ne devrait pas accéder aux PV internes: {res_doc_pv.status_code}"
    print("✓ Sécurité CDC §2.2 vérifiée : module interne PV strictement protégé contre les accès non autorisés (403).")

    print("\n=========================================================================")
    print("🎉 TOUS LES TESTS CDC §17 (PV) ET §18 (RECHERCHE GLOBALE) ONT RÉUSSI À 100% !")
    print("=========================================================================")

if __name__ == "__main__":
    run_tests()
