package com.lias.beans;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Entité JavaBean représentant un mandat de direction et de gouvernance du LIAS.
 */
public class Mandat implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String titre;
    private String directeurId;
    private String directeurNomComplet;
    private String viceDirecteurId;
    private String viceDirecteurNomComplet;
    private LocalDate dateDebut;
    private LocalDate dateFin;
    private boolean actif;
    private String chefsEquipes;

    public Mandat() {
    }

    public Mandat(Long id, String titre, String directeurId, String viceDirecteurId, LocalDate dateDebut, LocalDate dateFin, boolean actif) {
        this(id, titre, directeurId, viceDirecteurId, dateDebut, dateFin, actif, null);
    }

    public Mandat(Long id, String titre, String directeurId, String viceDirecteurId, LocalDate dateDebut, LocalDate dateFin, boolean actif, String chefsEquipes) {
        this.id = id;
        this.titre = titre;
        this.directeurId = directeurId;
        this.viceDirecteurId = viceDirecteurId;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.actif = actif;
        this.chefsEquipes = chefsEquipes;
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

    public String getDirecteurId() {
        return directeurId;
    }

    public void setDirecteurId(String directeurId) {
        this.directeurId = directeurId;
    }

    public String getDirecteurNomComplet() {
        return directeurNomComplet;
    }

    public void setDirecteurNomComplet(String directeurNomComplet) {
        this.directeurNomComplet = directeurNomComplet;
    }

    public String getViceDirecteurId() {
        return viceDirecteurId;
    }

    public void setViceDirecteurId(String viceDirecteurId) {
        this.viceDirecteurId = viceDirecteurId;
    }

    public String getViceDirecteurNomComplet() {
        return viceDirecteurNomComplet;
    }

    public void setViceDirecteurNomComplet(String viceDirecteurNomComplet) {
        this.viceDirecteurNomComplet = viceDirecteurNomComplet;
    }

    public LocalDate getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDate dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDate getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDate dateFin) {
        this.dateFin = dateFin;
    }

    public boolean isActif() {
        return actif;
    }

    public void setActif(boolean actif) {
        this.actif = actif;
    }

    public String getChefsEquipes() {
        return chefsEquipes;
    }

    public void setChefsEquipes(String chefsEquipes) {
        this.chefsEquipes = chefsEquipes;
    }
}
