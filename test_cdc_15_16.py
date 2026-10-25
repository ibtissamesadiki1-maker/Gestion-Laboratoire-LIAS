import requests
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

BASE_URL = "http://localhost:8080"

def run_tests():
    print("=== DÉBUT DES TESTS AUTOMATISÉS : SECTIONS 15 & 16 ===")
    session_dir = requests.Session()
    session_doc = requests.Session()
    session_perm = requests.Session()

    # -------------------------------------------------------------------------
    # 1. Authentifications
    # -------------------------------------------------------------------------
    print("\n--- 1. Authentification des acteurs ---")
    r_dir = session_dir.post(f"{BASE_URL}/login", data={"email": "directeur@lias.ma", "password": "admin123"}, allow_redirects=True)
    assert r_dir.status_code == 200, "Échec login directeur"
    print("✓ Connexion Directeur réussie.")

    r_doc = session_doc.post(f"{BASE_URL}/login", data={"email": "doctorant@lias.ma", "password": "doc123"}, allow_redirects=True)
    assert r_doc.status_code == 200, "Échec login doctorant"
    print("✓ Connexion Doctorant réussie.")

    r_perm = session_perm.post(f"{BASE_URL}/login", data={"email": "permanent@lias.ma", "password": "pass123"}, allow_redirects=True)
    assert r_perm.status_code == 200, "Échec login permanent"
    print("✓ Connexion Enseignant-Chercheur Permanent réussie.")

    # -------------------------------------------------------------------------
    # 2. SECTION 15 : Soumission des demandes de matériel
    # -------------------------------------------------------------------------
    print("\n--- 2. SECTION 15 : Soumission d'une demande par un Doctorant ---")
    res_page_besoins = session_doc.get(f"{BASE_URL}/besoins-materiel")
    assert res_page_besoins.status_code == 200, f"Erreur GET /besoins-materiel: {res_page_besoins.status_code}"
    html_besoins = res_page_besoins.text
    assert "Demandes en attente d'arbitrage" in html_besoins
    assert "Demandes accordées & dotées" in html_besoins
    assert "Historique complet" in html_besoins
    print("✓ Interface des besoins en matériel accessible avec tous ses onglets.")

    besoin_gpu = "Serveur d'Inférence IA vLLM 4x L40S"
    post_besoin = session_doc.post(f"{BASE_URL}/besoins-materiel", data={
        "action": "soumettre",
        "designation": besoin_gpu,
        "categorie": "Calcul / Serveur",
        "priorite": "URGENTE",
        "coutEstime": "85000",
        "justification": "Thèse doctorale : Déploiement local de modèles multimodaux",
        "description": "Besoin critique pour les tests d'inférence en temps réel sur les dialectes maghrébins"
    }, allow_redirects=True)
    assert post_besoin.status_code == 200
    html_after_post = post_besoin.text
    assert besoin_gpu in html_after_post, "Le besoin soumis n'apparaît pas dans la liste"
    assert "URGENTE" in html_after_post, "Le badge de priorité URGENTE n'apparaît pas"
    print(f"✓ Demande de matériel '{besoin_gpu}' soumise avec succès (statut: EN_ATTENTE).")

    # -------------------------------------------------------------------------
    # 3. SECTION 15 : Validation par la Direction (Accorder)
    # -------------------------------------------------------------------------
    print("\n--- 3. SECTION 15 : Validation et arbitrage par la Direction ---")
    # Trouver l'ID de la demande soumise
    res_dir_b = session_dir.get(f"{BASE_URL}/besoins-materiel")
    import re
    m_id = re.search(r'name="id"\s+value="(\d+)"', res_dir_b.text)
    assert m_id is not None, "Impossible de trouver une demande à valider"
    demande_id = m_id.group(1)

    post_accord = session_dir.post(f"{BASE_URL}/besoins-materiel", data={
        "action": "valider",
        "id": demande_id,
        "statut": "ACCORDE",
        "commentaire": "Validé et alloué sur subvention équipement CNRST 2026."
    }, allow_redirects=True)
    assert post_accord.status_code == 200
    html_after_accord = post_accord.text
    assert "Validé et alloué sur subvention" in html_after_accord or "ACCORDE" in html_after_accord
    print(f"✓ Demande #{demande_id} validée et accordée avec succès par la Direction.")

    # -------------------------------------------------------------------------
    # 4. SECTION 15 : Soumission et Refus avec motif par la Direction
    # -------------------------------------------------------------------------
    print("\n--- 4. SECTION 15 : Rejet d'une demande avec motif formel ---")
    besoin_drone = "Drone Professionnel DJI Matrice 350 RTK"
    post_perm = session_perm.post(f"{BASE_URL}/besoins-materiel", data={
        "action": "soumettre",
        "designation": besoin_drone,
        "categorie": "Périphérique",
        "priorite": "FAIBLE",
        "coutEstime": "45000",
        "justification": "Projet cartographie lidar",
        "description": "Acquisition pour prises de vue aériennes"
    }, allow_redirects=True)
    assert post_perm.status_code == 200

    res_dir_ref = session_dir.get(f"{BASE_URL}/besoins-materiel")
    m_id_ref = re.search(r'name="id"\s+value="(\d+)"', res_dir_ref.text)
    ref_id = m_id_ref.group(1)

    motif_refus = "Enveloppe budgétaire insuffisante sur l'exercice en cours. Reporté à l'année prochaine."
    post_refus = session_dir.post(f"{BASE_URL}/besoins-materiel", data={
        "action": "valider",
        "id": ref_id,
        "statut": "REFUSE",
        "commentaire": motif_refus
    }, allow_redirects=True)
    assert post_refus.status_code == 200
    html_after_refus = post_refus.text
    assert "REFUSE" in html_after_refus, "Statut REFUSE absent"
    assert "Enveloppe budgétaire insuffisante" in html_after_refus, "Motif du refus absent de la traçabilité"
    print(f"✓ Demande #{ref_id} refusée avec motif officiel consigné dans l'historique.")

    # -------------------------------------------------------------------------
    # 5. SECTION 16 : Consultation des conventions et partenaires
    # -------------------------------------------------------------------------
    print("\n--- 5. SECTION 16 : Consultation du répertoire des conventions & partenaires ---")
    res_conv = session_dir.get(f"{BASE_URL}/conventions")
    assert res_conv.status_code == 200, f"Erreur GET /conventions: {res_conv.status_code}"
    html_conv = res_conv.text
    assert "Répertoire des Conventions" in html_conv, "Onglet répertoire absent"
    assert "Suivi des Activités Associées" in html_conv, "Onglet activités associées absent"
    assert "Archivage Documentaire des Accords" in html_conv, "Onglet archivage absent"

    assert "CNRST" in html_conv, "Partenaire CNRST absent"
    assert "OCP Group" in html_conv, "Partenaire OCP absent"
    print("✓ Répertoire officiel des partenaires et conventions conforme.")

    # -------------------------------------------------------------------------
    # 6. SECTION 16 : Création d'une nouvelle convention avec document
    # -------------------------------------------------------------------------
    print("\n--- 6. SECTION 16 : Création d'une nouvelle convention de partenariat ---")
    partenaire_inria = "Inria Paris / Centre de Recherche Saclay"
    post_conv = session_dir.post(f"{BASE_URL}/conventions", data={
        "organismePartenaire": partenaire_inria,
        "typePartenaire": "Académique",
        "objet": "Recherche conjointe sur les architectures Zero-Trust et l'IA sécurisée",
        "dateSignature": "2026-03-01",
        "dateEcheance": "2029-02-28",
        "budgetAlloue": "350000",
        "statut": "Active",
        "referentLias": "Prof. Karim Zouhair",
        "contactPartenaire": "Dr. J. Dupont (Coordinateur Inria)",
        "documentSignePath": "archives/conventions/accord_inria_lias_2026.pdf"
    }, allow_redirects=True)
    assert post_conv.status_code == 200
    html_after_conv = post_conv.text
    assert partenaire_inria in html_after_conv, "La convention Inria n'apparaît pas"
    assert "accord_inria_lias_2026.pdf" in html_after_conv, "Le document archivé n'est pas référencé"
    print(f"✓ Convention avec '{partenaire_inria}' créée et archivée avec succès.")

    # -------------------------------------------------------------------------
    # 7. SECTION 16 : Suivi des activités associées (Thèse en cotutelle / Projet)
    # -------------------------------------------------------------------------
    print("\n--- 7. SECTION 16 : Ajout et suivi d'une activité associée à une convention ---")
    titre_act = "Stage doctoral immersif de 3 mois au centre Inria Saclay"
    post_act = session_dir.post(f"{BASE_URL}/conventions", data={
        "action": "ajouter_activite",
        "conventionId": "1",
        "titreActivite": titre_act,
        "typeActivite": "Mobilité Doctorale",
        "dateActivite": "2026-05-15",
        "responsable": "Prof. Karim Zouhair",
        "statut": "Planifiée",
        "livrableDescription": "Publication conjointe à ICIS et rapport de mobilité"
    }, allow_redirects=True)
    assert post_act.status_code == 200
    html_after_act = post_act.text
    assert titre_act in html_after_act, "L'activité associée ajoutée n'apparaît pas"
    assert "Mobilité Doctorale" in html_after_act, "Le type de l'activité n'apparaît pas"
    print(f"✓ Activité associée '{titre_act}' ajoutée et rattachée avec succès à la convention.")

    # -------------------------------------------------------------------------
    # 8. SECTION 16 : Téléchargement / Consultation du document archivé
    # -------------------------------------------------------------------------
    print("\n--- 8. SECTION 16 : Test du téléchargement du document archivé ---")
    res_dl = session_dir.get(f"{BASE_URL}/conventions?action=telecharger&id=1")
    assert res_dl.status_code == 200, f"Erreur téléchargement document: {res_dl.status_code}"
    assert "application/pdf" in res_dl.headers.get("Content-Type", ""), "Type de contenu non PDF"
    print("✓ Téléchargement du document d'accord archivé (PDF) opérationnel.")

    print("\n========================================================================")
    print("🎉 TOUS LES TESTS DES SECTIONS 15 ET 16 ONT RÉUSSI À 100% !")
    print("========================================================================")

if __name__ == "__main__":
    run_tests()
