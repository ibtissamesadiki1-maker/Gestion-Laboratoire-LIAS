package com.lias.beans;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Entité JavaBean représentant un procès-verbal (PV) officiel d'assemblée ou de conseil de laboratoire.
 * (CDC §17 ⭐ Procès-verbaux : Création des réunions, Ordre du jour, Upload des PV, Archivage).
 */
public class ReunionPV implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String titre;
    private String typeReunion;
    private LocalDate dateReunion;
    private String heure;
    private String lieu;
    private String ordreDuJour;
    private String cheminFichierPV;
    private String directeurSignataire;
    private String secretaireSeance;
    private String statut;

    public ReunionPV() {
        this.typeReunion = "Conseil de Laboratoire";
        this.heure = "10:00 - 12:30";
        this.lieu = "Salle de Réunion LIAS - FSBM";
        this.directeurSignataire = "Prof. Ibtissam Essadiki";
        this.secretaireSeance = "Secrétariat LIAS";
        this.statut = "ARCHIVEE";
    }

    public ReunionPV(Long id, String titre, String typeReunion, LocalDate dateReunion, String heure, String lieu,
                     String ordreDuJour, String cheminFichierPV, String directeurSignataire, String secretaireSeance, String statut) {
        this.id = id;
        this.titre = titre;
        this.typeReunion = typeReunion != null ? typeReunion : "Conseil de Laboratoire";
        this.dateReunion = dateReunion;
        this.heure = heure != null ? heure : "10:00 - 12:30";
        this.lieu = lieu != null ? lieu : "Salle de Réunion LIAS - FSBM";
        this.ordreDuJour = ordreDuJour;
        this.cheminFichierPV = cheminFichierPV;
        this.directeurSignataire = directeurSignataire != null ? directeurSignataire : "Prof. Ibtissam Essadiki";
        this.secretaireSeance = secretaireSeance != null ? secretaireSeance : "Secrétariat LIAS";
        this.statut = statut != null ? statut : "ARCHIVEE";
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

    public String getTypeReunion() {
        return typeReunion;
    }

    public void setTypeReunion(String typeReunion) {
        this.typeReunion = typeReunion;
    }

    public LocalDate getDateReunion() {
        return dateReunion;
    }

    public void setDateReunion(LocalDate dateReunion) {
        this.dateReunion = dateReunion;
    }

    public String getHeure() {
        return heure;
    }

    public void setHeure(String heure) {
        this.heure = heure;
    }

    public String getLieu() {
        return lieu;
    }

    public void setLieu(String lieu) {
        this.lieu = lieu;
    }

    public String getOrdreDuJour() {
        return ordreDuJour;
    }

    public void setOrdreDuJour(String ordreDuJour) {
        this.ordreDuJour = ordreDuJour;
    }

    public String getCheminFichierPV() {
        return cheminFichierPV;
    }

    public void setCheminFichierPV(String cheminFichierPV) {
        this.cheminFichierPV = cheminFichierPV;
    }

    public String getDirecteurSignataire() {
        return directeurSignataire;
    }

    public void setDirecteurSignataire(String directeurSignataire) {
        this.directeurSignataire = directeurSignataire;
    }

    public String getSecretaireSeance() {
        return secretaireSeance;
    }

    public void setSecretaireSeance(String secretaireSeance) {
        this.secretaireSeance = secretaireSeance;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }
}
