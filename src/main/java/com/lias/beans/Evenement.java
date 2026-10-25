package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant un évènement scientifique (CDC §9).
 */
public class Evenement implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String titre;
    private String type;         // Conférence, Séminaire, Workshop
    private String date;         // Date au format YYYY-MM-DD
    private String lieu;
    private String description;
    private String organisateur; // Nom du membre responsable
    private String statut;       // À venir, En cours, Passé, Archivé
    private String edition;      // Édition / Année (ex: "Édition 2026", "Édition 2025") CDC §9
    private String programme;    // Ordre du jour, planning ou note d'organisation (CDC §9)

    public Evenement() {
        super();
    }

    public Evenement(Long id, String titre, String type, String date, String lieu, String description, String organisateur, String statut) {
        this(id, titre, type, date, lieu, description, organisateur, statut, "Édition 2026", null);
    }

    public Evenement(Long id, String titre, String type, String date, String lieu, String description, String organisateur, String statut, String edition) {
        this(id, titre, type, date, lieu, description, organisateur, statut, edition, null);
    }

    public Evenement(Long id, String titre, String type, String date, String lieu, String description, String organisateur, String statut, String edition, String programme) {
        this.id = id;
        this.titre = titre;
        this.type = type;
        this.date = date;
        this.lieu = lieu;
        this.description = description;
        this.organisateur = organisateur;
        this.statut = statut;
        this.edition = edition != null ? edition : "Édition 2026";
        this.programme = programme;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitre() {
        return titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getLieu() {
        return lieu;
    }

    public void setLieu(String lieu) {
        this.lieu = lieu;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getOrganisateur() {
        return organisateur;
    }

    public void setOrganisateur(String organisateur) {
        this.organisateur = organisateur;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getEdition() {
        return edition;
    }

    public void setEdition(String edition) {
        this.edition = edition;
    }

    public String getProgramme() {
        return programme;
    }

    public void setProgramme(String programme) {
        this.programme = programme;
    }
}
