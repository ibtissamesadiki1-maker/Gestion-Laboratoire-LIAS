package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant un document archivé du laboratoire (CDC §10).
 * Structuration : Par événement et par date.
 * Types : Demandes de financement, Programmes, Attestations, Rapports, Documents administratifs.
 * Fonctionnalités : Upload, Téléchargement, Recherche, Historisation.
 */
public class DocumentLabo implements Serializable {
    private static final long serialVersionUID = 1L;

    private Integer id;
    private String dossier;         // ex: "Évènements", "Administratif"
    private String sousDossier;     // ex: "CASA-DATA", "Journée Scientifique", "Conventions"
    private String editionRubrique; // ex: "Édition 2026", "2025 — 7e édition", null
    private String nomFichier;      // ex: "Programme_Journee_LIAS_2026.pdf"
    private String taille;          // ex: "412 KB", "1.2 MB"
    private String dateFichier;     // ex: "2026-04-15" (Structuration par date CDC §10)
    private String type;            // extension format : "pdf", "docx", "xlsx", "zip"
    private String auteur;          // ex: "Prof. Ibtissam Essadiki"
    private String description;
    
    // CDC §10 : Types officiels de documents & Structuration par événement
    private String categorie;       // Demandes de financement, Programmes, Attestations, Rapports, Documents administratifs
    private String evenementNom;    // Nom de l'événement associé (CDC §10 : Structuration par événement)

    public DocumentLabo() {
    }

    public DocumentLabo(Integer id, String dossier, String sousDossier, String editionRubrique,
                        String nomFichier, String taille, String dateFichier, String type, String auteur, String description) {
        this(id, dossier, sousDossier, editionRubrique, nomFichier, taille, dateFichier, type, auteur, description, "Rapports", null);
    }

    public DocumentLabo(Integer id, String dossier, String sousDossier, String editionRubrique,
                        String nomFichier, String taille, String dateFichier, String type, String auteur, 
                        String description, String categorie, String evenementNom) {
        this.id = id;
        this.dossier = dossier;
        this.sousDossier = sousDossier;
        this.editionRubrique = editionRubrique;
        this.nomFichier = nomFichier;
        this.taille = taille;
        this.dateFichier = dateFichier;
        this.type = type;
        this.auteur = auteur;
        this.description = description;
        this.categorie = categorie != null && !categorie.trim().isEmpty() ? categorie : "Rapports";
        this.evenementNom = evenementNom != null && !evenementNom.trim().isEmpty() ? evenementNom : sousDossier;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getDossier() {
        return dossier;
    }

    public void setDossier(String dossier) {
        this.dossier = dossier;
    }

    public String getSousDossier() {
        return sousDossier;
    }

    public void setSousDossier(String sousDossier) {
        this.sousDossier = sousDossier;
    }

    public String getEditionRubrique() {
        return editionRubrique;
    }

    public void setEditionRubrique(String editionRubrique) {
        this.editionRubrique = editionRubrique;
    }

    public String getNomFichier() {
        return nomFichier;
    }

    public void setNomFichier(String nomFichier) {
        this.nomFichier = nomFichier;
    }

    public String getTaille() {
        return taille;
    }

    public void setTaille(String taille) {
        this.taille = taille;
    }

    public String getDateFichier() {
        return dateFichier;
    }

    public void setDateFichier(String dateFichier) {
        this.dateFichier = dateFichier;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getAuteur() {
        return auteur;
    }

    public void setAuteur(String auteur) {
        this.auteur = auteur;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategorie() {
        return categorie;
    }

    public void setCategorie(String categorie) {
        this.categorie = categorie;
    }

    public String getEvenementNom() {
        return evenementNom;
    }

    public void setEvenementNom(String evenementNom) {
        this.evenementNom = evenementNom;
    }

    public String getCheminComplet() {
        StringBuilder sb = new StringBuilder();
        if (dossier != null) sb.append(dossier);
        if (evenementNom != null && !evenementNom.trim().isEmpty()) {
            sb.append(" / ").append(evenementNom);
        } else if (sousDossier != null) {
            sb.append(" / ").append(sousDossier);
        }
        if (editionRubrique != null && !editionRubrique.trim().isEmpty()) sb.append(" / ").append(editionRubrique);
        return sb.toString();
    }
}
