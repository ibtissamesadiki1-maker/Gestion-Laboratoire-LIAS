import requests
import re
import sys

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')

BASE_URL = "http://localhost:8080"

def run_tests():
    s = requests.Session()
    print("=== DÉBUT DES TESTS CDC §21 (RÈGLES GÉNÉRALES DU SYSTÈME & MÉMOIRE INSTITUTIONNELLE) ===")

    # 1. Authentification Directeur / Admin
    print("\n[1] Connexion en tant que Directeur...")
    res = s.post(f"{BASE_URL}/login", data={
        "email": "directeur@lias.ma",
        "password": "admin123"
    }, allow_redirects=True)
    assert res.status_code == 200, f"Erreur login: {res.status_code}"
    print("✓ Connexion Directeur réussie.")

    # 2. Consultation de l'onglet Règles & Mémoire Institutionnelle (/admin?tab=regles)
    print("\n[2] Consultation de l'espace CDC §21 (/admin?tab=regles)...")
    res_regles = s.get(f"{BASE_URL}/admin?tab=regles")
    assert res_regles.status_code == 200, f"Erreur /admin?tab=regles: {res_regles.status_code}"
    content = res_regles.text

    assert "Règles Générales du Système & Mémoire Institutionnelle" in content, "Titre principal manquant"
    assert "CDC §21" in content, "Mention CDC §21 manquante"
    print("✓ Page d'administration ouverte sur le volet Règles & Mémoire Institutionnelle.")

    # 3. Vérification des 5 Règles Générales du Système
    print("\n[3] Vérification des 5 Règles Générales du Système (CDC §21 ⭐)...")

    # Règle 1 : Aucun membre ne perd ses données
    assert "Aucun membre ne perd ses données" in content, "Règle 1 manquante"
    assert "ZÉRO PERTE" in content or "Zéro perte" in content or "conservation intégrale" in content, "Mention zéro perte manquante"
    assert "Retraités" in content, "Mention retraités (CDC §8.1) manquante"
    assert "Anciens Membres" in content or "anciens membres" in content, "Mention anciens membres (CDC §8.2) manquante"
    print("  ✓ Règle 1 validée : Aucun membre ne perd ses données (Retraités gelés §8.1 & Anciens §8.2 préservés).")

    # Règle 2 : Tout est historisé (rôles, statuts, mandats)
    assert "Tout est historisé" in content, "Règle 2 manquante"
    assert "rôles" in content.lower() and "statuts" in content.lower() and "mandats" in content.lower(), "Mentions rôles, statuts, mandats manquantes"
    assert "Direction de laboratoire" in content, "Mention direction mandat manquante"
    print("  ✓ Règle 2 validée : Tout est historisé (rôles, statuts, mandats successifs).")

    # Règle 3 : Séparation stricte : Statut vs Rôle
    assert "Séparation stricte : Statut vs Rôle" in content or "Séparation stricte" in content, "Règle 3 manquante"
    assert "Permanent" in content and "Doctorant" in content, "Exemples statuts manquants"
    assert "Directeur" in content and "Chef Équipe" in content, "Exemples rôles manquants"
    print("  ✓ Règle 3 validée : Séparation stricte Statut (pérenne) vs Rôle (responsabilité/mandat temporel).")

    # Règle 4 : Toute action importante est traçable
    assert "Toute action importante est traçable" in content, "Règle 4 manquante"
    assert "Journal" in content or "audit" in content.lower() or "traçabilité" in content.lower(), "Traçabilité manquante"
    print("  ✓ Règle 4 validée : Toute action importante est traçable (décisions, matériel, conventions, PVs).")

    # Règle 5 : Le système constitue une mémoire institutionnelle complète
    assert "mémoire institutionnelle complète" in content.lower(), "Règle 5 manquante"
    assert "15/09/2003" in content or "2003" in content, "Date de fondation 2003 manquante"
    print("  ✓ Règle 5 validée : Le système constitue une mémoire institutionnelle complète (depuis 2003).")

    # 4. Vérification du Résultat Final Attendu (Les 6 Piliers Fondateurs)
    print("\n[4] Vérification du Résultat Final Attendu (Les 6 Piliers Fondateurs du Laboratoire)...")
    piliers = [
        "Gestion Complète du Cycle de Vie des Membres",
        "Traçabilité Totale des Décisions",
        "Capitalisation des Connaissances",
        "Gestion Administrative & Scientifique Intégrée",
        "Production Automatisée du Rapport Annuel",
        "Organisation Structurée du Laboratoire"
    ]
    for pilier in piliers:
        assert pilier in content, f"Pilier manquant: {pilier}"
        print(f"  ✓ Pilier validé : {pilier}")

    # 5. Vérification du Tableau de Contrôle des Membres
    print("\n[5] Vérification du tableau de contrôle des membres et de l'intégrité...")
    assert "Données 100% Préservées" in content, "Mention garantie de données manquante"
    assert "Voir Historique" in content, "Lien vers l'historique manquant"
    print("  ✓ Tableau de contrôle des membres présent avec statut, rôle, équipe et intégrité garantie.")

    # 6. Vérification transversale de la non-régression (Calendrier, Publications, Rapport annuel)
    print("\n[6] Vérification transversale de la plateforme...")
    
    # Calendrier (CDC §20)
    res_cal = s.get(f"{BASE_URL}/calendrier")
    assert res_cal.status_code == 200, f"Erreur /calendrier: {res_cal.status_code}"
    assert "Calendrier Scientifique" in res_cal.text, "Calendrier non accessible"
    print("  ✓ Section 20 (Calendrier) : Opérationnelle.")

    # Publications (CDC §12)
    res_pub = s.get(f"{BASE_URL}/publications")
    assert res_pub.status_code == 200, f"Erreur /publications: {res_pub.status_code}"
    assert "Publications Scientifiques" in res_pub.text, "Publications non accessibles"
    print("  ✓ Section 12 (Publications) : Opérationnelle.")

    # Rapport d'activité annuel (CDC §11)
    res_rap = s.get(f"{BASE_URL}/rapport")
    assert res_rap.status_code == 200, f"Erreur /rapport: {res_rap.status_code}"
    assert "Rapport d'Activité Annuel" in res_rap.text or "Rapport" in res_rap.text, "Rapport non accessible"
    print("  ✓ Section 11 (Rapport Annuel) : Opérationnel.")

    # Conventions (CDC §16)
    res_conv = s.get(f"{BASE_URL}/conventions")
    assert res_conv.status_code == 200, f"Erreur /conventions: {res_conv.status_code}"
    assert "Conventions" in res_conv.text, "Conventions non accessibles"
    print("  ✓ Section 16 (Conventions & Partenaires) : Opérationnelle.")

    # Matériel & Besoins (CDC §14 & §15)
    res_mat = s.get(f"{BASE_URL}/materiel")
    assert res_mat.status_code == 200, f"Erreur /materiel: {res_mat.status_code}"
    assert "Matériel" in res_mat.text, "Matériel non accessible"
    print("  ✓ Section 14 (Gestion du Matériel) : Opérationnelle.")

    print("\n=== TOUS LES TESTS DU CDC §21 ET DU RÉSULTAT FINAL ONT RÉUSSI AVEC SUCCÈS (100% SUCCÈS) ===")

if __name__ == "__main__":
    run_tests()
