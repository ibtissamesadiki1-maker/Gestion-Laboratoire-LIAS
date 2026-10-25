package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant une demande et allocation de matériel (CDC §14 & §15).
 * Permet la soumission des besoins, la validation par la Direction, et l'historique complet.
 */
public class Materiel implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String designation;   // ex: PC Portable Dell XPS, Serveur GPU, Écran 4K
    private String categorie;     // Informatique, Calcul, Réseau
    private String demandeur;     // Nom du chercheur
    private String dateDemande;
    private String statut;        // EN_ATTENTE, ACCORDE, LIVRE, REFUSE
    private String dateAttribution;
    private String commentaire;
    private String priorite;      // URGENTE, NORMALE, FAIBLE (CDC §15)
    private Double coutEstime;    // Coût estimatif prévisionnel en MAD (CDC §15)

    public Materiel() {
        super();
        this.priorite = "NORMALE";
    }

    public Materiel(Long id, String designation, String categorie, String demandeur, String dateDemande, String statut, String dateAttribution, String commentaire) {
        this(id, designation, categorie, demandeur, dateDemande, statut, dateAttribution, commentaire, "NORMALE", null);
    }

    public Materiel(Long id, String designation, String categorie, String demandeur, String dateDemande, String statut, String dateAttribution, String commentaire, String priorite, Double coutEstime) {
        this.id = id;
        this.designation = designation;
        this.categorie = categorie;
        this.demandeur = demandeur;
        this.dateDemande = dateDemande;
        this.statut = statut;
        this.dateAttribution = dateAttribution;
        this.commentaire = commentaire;
        this.priorite = (priorite != null && !priorite.trim().isEmpty()) ? priorite : "NORMALE";
        this.coutEstime = coutEstime;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public String getCategorie() {
        return categorie;
    }

    public void setCategorie(String categorie) {
        this.categorie = categorie;
    }

    public String getDemandeur() {
        return demandeur;
    }

    public void setDemandeur(String demandeur) {
        this.demandeur = demandeur;
    }

    public String getDateDemande() {
        return dateDemande;
    }

    public void setDateDemande(String dateDemande) {
        this.dateDemande = dateDemande;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getDateAttribution() {
        return dateAttribution;
    }

    public void setDateAttribution(String dateAttribution) {
        this.dateAttribution = dateAttribution;
    }

    public String getCommentaire() {
        return commentaire;
    }

    public void setCommentaire(String commentaire) {
        this.commentaire = commentaire;
    }

    public String getPriorite() {
        return priorite != null ? priorite : "NORMALE";
    }

    public void setPriorite(String priorite) {
        this.priorite = priorite;
    }

    public Double getCoutEstime() {
        return coutEstime;
    }

    public void setCoutEstime(Double coutEstime) {
        this.coutEstime = coutEstime;
    }
}
