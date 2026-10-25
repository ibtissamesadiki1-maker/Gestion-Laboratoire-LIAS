package com.lias.dao;

import java.util.List;
import com.lias.beans.DocumentLabo;

/**
 * Interface DAO pour la gestion de l'archive documentaire (CDC §10).
 * Structuration : Par événement et par date.
 * Types de documents : Demandes de financement, Programmes, Attestations, Rapports, Documents administratifs.
 * Fonctionnalités : Upload, Téléchargement, Recherche, Historisation.
 */
public interface IDocumentDao {
    List<DocumentLabo> findAll();
    List<DocumentLabo> findByCategorie(String categorie);
    List<DocumentLabo> findByEvenement(String evenementNom);
    List<DocumentLabo> findByDossier(String dossier, String sousDossier, String editionRubrique);
    List<DocumentLabo> search(String query);
    List<DocumentLabo> searchFiltered(String query, String categorie, String evenementNom, String annee);
    List<DocumentLabo> findRecentHistorique(int limit);
    List<String> findDistinctEvenements();
    DocumentLabo findById(int id);
    boolean save(DocumentLabo document);
    boolean delete(int id);
}
