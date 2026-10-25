package com.lias.dao;

import java.util.List;
import com.lias.beans.Evenement;

/**
 * Interface DAO pour la gestion des événements scientifiques (CDC §9).
 * Types : Conférences, Séminaires, Workshops.
 * Fonctionnalités : Création, Organisation, Archivage par édition, Affectation d'organisateurs.
 */
public interface IEvenementDao {
    List<Evenement> findAll();
    List<Evenement> findByType(String type);
    List<Evenement> findByEdition(String edition);
    List<String> findEditions();
    Evenement findById(Long id);
    boolean save(Evenement evt);
    boolean updateOrganisation(Long id, String titre, String type, String date, String lieu, String description, String programme, String organisateur, String statut, String edition);
    boolean affecterOrganisateur(Long id, String organisateur);
    boolean archiverEdition(Long id, String edition);
    boolean delete(Long id);
}
