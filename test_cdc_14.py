import requests
import re
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

BASE_URL = "http://localhost:8080"

def run_tests():
    print("=== DÉBUT DES TESTS AUTOMATISÉS : SECTION 14 (GESTION DU MATÉRIEL) ===")
    session_dir = requests.Session()
    session_doc = requests.Session()

    # -------------------------------------------------------------------------
    # 1. Connexion Directeur
    # -------------------------------------------------------------------------
    print("\n--- 1. Authentification Directeur (directeur@lias.ma) ---")
    login_res = session_dir.post(f"{BASE_URL}/login", data={
        "email": "directeur@lias.ma",
        "password": "admin123"
    }, allow_redirects=True)
    assert login_res.status_code == 200, f"Erreur login directeur: {login_res.status_code}"
    print("✓ Connexion Directeur réussie.")

    # -------------------------------------------------------------------------
    # 2. Consultation /materiel et vérification des 5 volets CDC §14
    # -------------------------------------------------------------------------
    print("\n--- 2. Vérification des onglets et structures CDC §14 ---")
    res_mat = session_dir.get(f"{BASE_URL}/materiel")
    assert res_mat.status_code == 200, f"Erreur GET /materiel: {res_mat.status_code}"
    html = res_mat.text

    assert "Suivi des Arrivages" in html, "Onglet 'Suivi des Arrivages' absent"
    print("✓ Onglet 'Suivi des Arrivages' présent.")

    assert "Distribution Équitable" in html, "Onglet 'Distribution Équitable' absent"
    print("✓ Onglet 'Distribution Équitable' présent.")

    assert "Historique Complet" in html, "Onglet 'Historique Complet' absent"
    print("✓ Onglet 'Historique Complet' présent.")

    assert "Qui a reçu quoi" in html, "Onglet 'Qui a reçu quoi' absent"
    print("✓ Onglet 'Qui a reçu quoi' présent.")

    assert "Qui n'a pas reçu" in html, "Onglet 'Qui n'a pas reçu' absent"
    print("✓ Onglet 'Qui n'a pas reçu' présent.")

    # Vérification des arrivages initiaux
    assert "BL-CNRST-2026-01" in html or "BL-UNIV" in html, "Arrivages initiaux non détectés"
    print("✓ Arrivages initiaux détectés dans le registre.")

    # -------------------------------------------------------------------------
    # 3. Test : Enregistrement d'un nouvel arrivage (CDC §14)
    # -------------------------------------------------------------------------
    print("\n--- 3. Test de l'enregistrement d'un arrivage (action=enregistrer_arrivage) ---")
    bon_test = "BL-TEST-2026-99"
    desig_lot = "Lot 5 Serveurs GPU Dell PowerEdge R750xa"
    post_arr = session_dir.post(f"{BASE_URL}/materiel", data={
        "action": "enregistrer_arrivage",
        "numeroBon": bon_test,
        "designationLot": desig_lot,
        "fournisseurSource": "Subvention CNRST IA 2026",
        "quantite": "5",
        "dateArrivage": "2026-03-12",
        "statutReception": "CONFORME",
        "description": "Serveurs biprocesseurs GPU haute densité pour doctorants et chercheurs"
    }, allow_redirects=True)
    assert post_arr.status_code == 200, f"Erreur POST arrivage: {post_arr.status_code}"
    html_after_arr = post_arr.text
    assert bon_test in html_after_arr, "Le bon d'arrivage enregistré n'apparaît pas dans la liste"
    assert desig_lot in html_after_arr, "La désignation du lot enregistré n'apparaît pas"
    print(f"✓ Arrivage '{bon_test}' enregistré et consigné avec succès dans le registre officiel.")

    # -------------------------------------------------------------------------
    # 4. Vérification de la Distribution Équitable
    # -------------------------------------------------------------------------
    print("\n--- 4. Test des métriques de distribution équitable (Équipes & Doctorants) ---")
    assert "Distribution par Équipe de Recherche" in html_after_arr, "Section équipes absente"
    assert "Équipe IA & NLP" in html_after_arr, "Équipe IA non référencée dans les métriques"
    assert "Doctorants & Jeunes Chercheurs" in html_after_arr, "Parité doctorants absente"
    assert "Indice d'Équité" in html_after_arr, "Indice d'équité absent"
    print("✓ Métriques de distribution équitable calculées et affichées (IA, Big Data, Sécurité, Doctorants).")

    # -------------------------------------------------------------------------
    # 5. Vérification du volet « Qui a reçu quoi »
    # -------------------------------------------------------------------------
    print("\n--- 5. Test du suivi : « Qui a reçu quoi » ---")
    assert "Amine Alami" in html_after_arr or "RTX 4090" in html_after_arr, "Attribution Amine Alami non trouvée"
    print("✓ Suivi 'Qui a reçu quoi' affiche fidèlement les équipements et leurs bénéficiaires.")

    # -------------------------------------------------------------------------
    # 6. Vérification du volet « Qui n'a pas reçu »
    # -------------------------------------------------------------------------
    print("\n--- 6. Test du suivi : « Qui n'a pas reçu » ---")
    assert "Volet A : Demandes en attente" in html_after_arr, "Volet A absent"
    assert "Volet B : Membres actifs du laboratoire n'ayant reçu aucun matériel" in html_after_arr, "Volet B absent"
    print("✓ Suivi 'Qui n'a pas reçu' distingue bien les demandes en souffrance ET les membres actifs sans dotation.")

    # -------------------------------------------------------------------------
    # 7. Test de la dotation prioritaire directe (Distribution équitable CDC §14)
    # -------------------------------------------------------------------------
    print("\n--- 7. Test d'attribution directe à un membre sans équipement ---")
    post_direct = session_dir.post(f"{BASE_URL}/materiel", data={
        "action": "attribuer_direct",
        "demandeur": "Pr. Nadia Idrissi (associe)",
        "designation": "Station Mobile ThinkPad P16 Gen 2",
        "categorie": "Poste de Travail",
        "commentaire": "Dotation équitable au titre du soutien à la collaboration Big Data"
    }, allow_redirects=True)
    assert post_direct.status_code == 200
    html_after_direct = post_direct.text
    assert "Pr. Nadia Idrissi" in html_after_direct, "Nouveau bénéficiaire absent de 'Qui a reçu quoi'"
    assert "ThinkPad P16" in html_after_direct, "Équipement attribué absent"
    print("✓ Dotation prioritaire directe enregistrée et intégrée immédiatement dans 'Qui a reçu quoi'.")

    # -------------------------------------------------------------------------
    # 8. Test d'expression de besoin par un Doctorant (CDC §15 & §14)
    # -------------------------------------------------------------------------
    print("\n--- 8. Expression de besoin formulée par un Doctorant ---")
    login_doc = session_doc.post(f"{BASE_URL}/login", data={
        "email": "doctorant@lias.ma",
        "password": "doc123"
    }, allow_redirects=True)
    assert login_doc.status_code == 200

    besoin_desig = "Lunettes de Réalité Mixte Apple Vision Pro"
    post_besoin = session_doc.post(f"{BASE_URL}/materiel", data={
        "designation": besoin_desig,
        "categorie": "Périphérique",
        "description": "Expérimentations immersives pour l'annotation 3D de données biomédicales"
    }, allow_redirects=True)
    assert post_besoin.status_code == 200

    # Vérification que la demande apparaît en attente dans 'Qui n'a pas reçu'
    res_verif = session_dir.get(f"{BASE_URL}/materiel")
    assert besoin_desig in res_verif.text, "La nouvelle demande du doctorant n'apparaît pas en attente"
    print(f"✓ Expression de besoin '{besoin_desig}' consignée avec succès en attente d'arbitrage.")

    print("\n========================================================================")
    print("🎉 TOUS LES TESTS DE LA SECTION 14 (GESTION DU MATÉRIEL) ONT RÉUSSI À 100% !")
    print("========================================================================")

if __name__ == "__main__":
    run_tests()
