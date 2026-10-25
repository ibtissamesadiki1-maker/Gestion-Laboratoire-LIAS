package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant une publication scientifique (CDC §12).
 */
public class Publication implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String titre;
    private String auteurs;      // Noms des auteurs séparés par des virgules
    private int annee;
    private String revue;        // Journal / Conférence
    private String doi;          // Lien ou identifiant DOI
    private String equipe;       // IA, Big Data, NLP, Sécurité
    private String type;         // Article, Conférence, Thèse, Brevet

    public Publication() {
        super();
    }

    public Publication(Long id, String titre, String auteurs, int annee, String revue, String doi, String equipe, String type) {
        this.id = id;
        this.titre = titre;
        this.auteurs = auteurs;
        this.annee = annee;
        this.revue = revue;
        this.doi = doi;
        this.equipe = equipe;
        this.type = type;
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

    public String getAuteurs() {
        return auteurs;
    }

    public void setAuteurs(String auteurs) {
        this.auteurs = auteurs;
    }

    public int getAnnee() {
        return annee;
    }

    public void setAnnee(int annee) {
        this.annee = annee;
    }

    public String getRevue() {
        return revue;
    }

    public void setRevue(String revue) {
        this.revue = revue;
    }

    public String getDoi() {
        return doi;
    }

    public void setDoi(String doi) {
        this.doi = doi;
    }

    public String getEquipe() {
        return equipe;
    }

    public void setEquipe(String equipe) {
        this.equipe = equipe;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
