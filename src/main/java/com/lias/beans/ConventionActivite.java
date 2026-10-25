package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant une activité scientifique ou opérationnelle rattachée à une convention (CDC §16).
 * Permet le suivi des activités associées : Thèses en cotutelle, projets R&D, mobilités, workshops.
 */
public class ConventionActivite implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long conventionId;
    private String titreActivite;
    private String typeActivite;       // "Projet R&D", "Thèse en Cotutelle", "Mobilité Doctorale", "Workshop Partenaire"
    private String dateActivite;
    private String responsable;        // Chercheur ou coordinateur responsable
    private String statut;             // "En cours", "Terminée", "Planifiée"
    private String livrableDescription;

    public ConventionActivite() {
        super();
        this.statut = "En cours";
    }

    public ConventionActivite(Long id, Long conventionId, String titreActivite, String typeActivite, String dateActivite, String responsable, String statut, String livrableDescription) {
        this.id = id;
        this.conventionId = conventionId;
        this.titreActivite = titreActivite;
        this.typeActivite = typeActivite;
        this.dateActivite = dateActivite;
        this.responsable = responsable;
        this.statut = (statut != null && !statut.trim().isEmpty()) ? statut : "En cours";
        this.livrableDescription = livrableDescription;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getConventionId() {
        return conventionId;
    }

    public void setConventionId(Long conventionId) {
        this.conventionId = conventionId;
    }

    public String getTitreActivite() {
        return titreActivite;
    }

    public void setTitreActivite(String titreActivite) {
        this.titreActivite = titreActivite;
    }

    public String getTypeActivite() {
        return typeActivite;
    }

    public void setTypeActivite(String typeActivite) {
        this.typeActivite = typeActivite;
    }

    public String getDateActivite() {
        return dateActivite;
    }

    public void setDateActivite(String dateActivite) {
        this.dateActivite = dateActivite;
    }

    public String getResponsable() {
        return responsable;
    }

    public void setResponsable(String responsable) {
        this.responsable = responsable;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getLivrableDescription() {
        return livrableDescription;
    }

    public void setLivrableDescription(String livrableDescription) {
        this.livrableDescription = livrableDescription;
    }
}
