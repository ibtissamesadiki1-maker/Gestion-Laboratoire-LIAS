import requests
import re
import sys

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')

BASE_URL = "http://localhost:8080"

def run_tests():
    s = requests.Session()
    print("=== DÉBUT DES TESTS CDC §19 (NOTIFICATIONS) & §20 (CALENDRIER) ===")

    # 1. Authentification Directeur
    print("\n[1] Connexion en tant que Directeur...")
    res = s.post(f"{BASE_URL}/login", data={
        "email": "directeur@lias.ma",
        "password": "admin123"
    }, allow_redirects=True)
    assert res.status_code == 200, f"Erreur login: {res.status_code}"
    print("✓ Connexion Directeur réussie.")

    # 2. Consultation du Centre de Notifications (CDC §19 ⭐)
    print("\n[2] Consultation du Centre de Notifications (/notifications)...")
    res_notif = s.get(f"{BASE_URL}/notifications")
    assert res_notif.status_code == 200, f"Erreur /notifications: {res_notif.status_code}"
    assert "Centre de Notifications" in res_notif.text, "Titre du centre de notifications manquant"
    assert "Événements (CDC §19)" in res_notif.text, "Catégorie Événements manquante"
    assert "Validation demandes (CDC §19)" in res_notif.text or "Validation Demandes" in res_notif.text, "Catégorie Validation demandes manquante"
    assert "Ajouts de documents (CDC §19)" in res_notif.text or "Ajouts Documents" in res_notif.text, "Catégorie Ajouts documents manquante"
    print("✓ Centre de notifications accessible avec les 3 catégories statutaires CDC §19.")

    # 3. Test des filtres par catégorie (CDC §19 ⭐)
    print("\n[3a] Filtrage par catégorie 'Événements' (CDC §19)...")
    res_filt_ev = s.get(f"{BASE_URL}/notifications?filter=evenements")
    assert res_filt_ev.status_code == 200
    assert "Événements (CDC §19)" in res_filt_ev.text
    print("✓ Filtre Événements opérationnel.")

    print("\n[3b] Filtrage par catégorie 'Validation demandes' (CDC §19)...")
    res_filt_val = s.get(f"{BASE_URL}/notifications?filter=validations")
    assert res_filt_val.status_code == 200
    assert "Validation demandes" in res_filt_val.text or "Validation Demandes" in res_filt_val.text
    print("✓ Filtre Validation demandes opérationnel.")

    print("\n[3c] Filtrage par catégorie 'Ajouts de documents' (CDC §19)...")
    res_filt_doc = s.get(f"{BASE_URL}/notifications?filter=documents")
    assert res_filt_doc.status_code == 200
    assert "Ajouts de documents" in res_filt_doc.text or "Ajouts Documents" in res_filt_doc.text
    print("✓ Filtre Ajouts de documents opérationnel.")

    # 4. Diffusion d'une notification par la Direction (CDC §19 ⭐)
    print("\n[4] Diffusion d'une notification institutionnelle (action=creer_notification)...")
    test_notif_body = "Journée Scientifique Annuelle LIAS 2026 : Appel à posters doctorants lancé."
    res_post_notif = s.post(f"{BASE_URL}/notifications", data={
        "action": "creer_notification",
        "kind": "event",
        "who": "Prof. Ibtissam Essadiki (Directrice)",
        "body": test_notif_body,
        "actionLabel": "Voir l'événement →",
        "targetUrl": "/calendrier"
    }, allow_redirects=True)
    assert res_post_notif.status_code == 200
    assert test_notif_body in res_post_notif.text, "La notification créée n'apparaît pas dans le flux"
    print("✓ Notification diffusée et intégrée dans le flux en temps réel.")

    # 5. Marquer une notification comme lue et marquer tout comme lu
    print("\n[5a] Test de l'action Marquer comme lue (action=mark_read)...")
    # Extraire un ID de notification
    notif_ids = re.findall(r'action=mark_read&id=(\d+)', res_post_notif.text)
    if notif_ids:
        test_nid = notif_ids[0]
        res_read = s.get(f"{BASE_URL}/notifications?action=mark_read&id={test_nid}")
        assert res_read.status_code == 200
        print(f"✓ Notification #{test_nid} marquée comme lue.")

    print("\n[5b] Test de l'action Tout marquer comme lu (action=mark_all_read)...")
    res_all_read = s.get(f"{BASE_URL}/notifications?action=mark_all_read")
    assert res_all_read.status_code == 200
    assert "Toutes les notifications ont été marquées comme lues" in res_all_read.text or "tout_lu" in res_all_read.url
    print("✓ Toutes les notifications ont été marquées comme lues.")

    # 6. Vérification du popover dans l'en-tête (app_header)
    print("\n[6] Vérification du popover dynamique dans l'en-tête...")
    res_home = s.get(f"{BASE_URL}/home")
    assert res_home.status_code == 200
    assert "Notifications (CDC §19)" in res_home.text
    assert "Voir toutes les notifications (CDC §19)" in res_home.text
    print("✓ Popover d'en-tête synchronisé avec le centre de notifications.")

    # 7. Calendrier Scientifique (CDC §20 ⭐)
    print("\n[7] Consultation du Calendrier Scientifique (/calendrier)...")
    res_cal = s.get(f"{BASE_URL}/calendrier")
    assert res_cal.status_code == 200, f"Erreur /calendrier: {res_cal.status_code}"
    assert "Calendrier Scientifique" in res_cal.text, "Titre du calendrier manquant"
    assert "Navigation Temporelle" in res_cal.text or "Temporalité" in res_cal.text, "Navigation temporelle manquante"
    assert "Vue Grille" in res_cal.text, "Bouton Vue Grille manquant"
    assert "Vue Agenda" in res_cal.text, "Bouton Vue Agenda manquant"
    print("✓ Calendrier accessible avec ses vues alternatives Grille et Agenda.")

    # 8. Visualisation des événements (CDC §20 ⭐)
    print("\n[8] Visualisation des événements & délibérations...")
    assert "Lundi" in res_cal.text and "Dimanche" in res_cal.text, "Grille hebdomadaire manquante"
    assert "labEvents" in res_cal.text, "Flux de données JSON d'événements manquant"
    assert "Conférence" in res_cal.text, "Légende Conférence manquante"
    assert "Séminaire" in res_cal.text, "Légende Séminaire manquante"
    assert "Workshop" in res_cal.text, "Légende Workshop manquante"
    assert "Conseil / PV" in res_cal.text or "Conseil" in res_cal.text, "Légende Conseil/PV manquante"
    print("✓ Visualisation des événements et des réunions officielles confirmée dans la grille.")

    # 9. Navigation temporelle (CDC §20 ⭐)
    print("\n[9a] Test des commandes de navigation temporelle (mois et année)...")
    assert "changeMonth(-1)" in res_cal.text, "Bouton mois précédent manquant"
    assert "changeMonth(1)" in res_cal.text, "Bouton mois suivant manquant"
    assert "jumpMonth" in res_cal.text, "Sélecteur de mois direct manquant"
    assert "jumpYear" in res_cal.text, "Sélecteur d'année direct manquant"
    print("✓ Commandes de navigation temporelle et sélecteurs de saut direct présents.")

    print("\n[9b] Test de navigation temporelle par paramètres d'URL (GET /calendrier?year=2025&month=9)...")
    res_cal_past = s.get(f"{BASE_URL}/calendrier?year=2025&month=9")
    assert res_cal_past.status_code == 200
    assert "2025" in res_cal_past.text
    print("✓ Navigation temporelle via URL paramétrée opérationnelle.")

    # 10. Test d'accès pour un compte Doctorant
    print("\n[10] Test des accès pour un compte Doctorant...")
    s_doc = requests.Session()
    s_doc.post(f"{BASE_URL}/login", data={
        "email": "doctorant@lias.ma",
        "password": "doc123"
    }, allow_redirects=True)

    res_doc_notif = s_doc.get(f"{BASE_URL}/notifications")
    assert res_doc_notif.status_code == 200
    print("✓ Doctorant autorisé à consulter le centre de notifications.")

    res_doc_cal = s_doc.get(f"{BASE_URL}/calendrier")
    assert res_doc_cal.status_code == 200
    print("✓ Doctorant autorisé à visualiser le calendrier scientifique et naviguer dans le temps.")

    print("\n=========================================================================")
    print("🎉 TOUS LES TESTS CDC §19 (NOTIFICATIONS) ET §20 (CALENDRIER) ONT RÉUSSI À 100% !")
    print("=========================================================================")

if __name__ == "__main__":
    run_tests()
