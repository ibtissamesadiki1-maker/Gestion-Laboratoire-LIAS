package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant une demande d'adhésion au laboratoire (CDC §6).
 */
public class DemandeAdhesion implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String statutVise;    // Permanent, Associé, Doctorant
    private String etablissement; // Faculté / Université d'origine
    private String motivation;
    private String dateSoumission;
    private String decision;      // EN_ATTENTE, ACCEPTEE, REFUSEE
    private String cvPath;        // Fichier ou URL du CV académique (CDC §6)

    public DemandeAdhesion() {
        super();
    }

    public DemandeAdhesion(Long id, String nom, String prenom, String email, String statutVise, String etablissement, String motivation, String dateSoumission, String decision) {
        this(id, nom, prenom, email, statutVise, etablissement, motivation, dateSoumission, decision, null);
    }

    public DemandeAdhesion(Long id, String nom, String prenom, String email, String statutVise, String etablissement, String motivation, String dateSoumission, String decision, String cvPath) {
        this.id = id;
        this.nom = nom;
        this.prenom = prenom;
        this.email = email;
        this.statutVise = statutVise;
        this.etablissement = etablissement;
        this.motivation = motivation;
        this.dateSoumission = dateSoumission;
        this.decision = decision;
        this.cvPath = cvPath != null ? cvPath : "dossiers/cv_" + (prenom != null ? prenom.toLowerCase() : "candidat") + ".pdf";
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getStatutVise() {
        return statutVise;
    }

    public void setStatutVise(String statutVise) {
        this.statutVise = statutVise;
    }

    public String getEtablissement() {
        return etablissement;
    }

    public void setEtablissement(String etablissement) {
        this.etablissement = etablissement;
    }

    public String getMotivation() {
        return motivation;
    }

    public void setMotivation(String motivation) {
        this.motivation = motivation;
    }

    public String getDateSoumission() {
        return dateSoumission;
    }

    public void setDateSoumission(String dateSoumission) {
        this.dateSoumission = dateSoumission;
    }

    public String getDecision() {
        return decision;
    }

    public void setDecision(String decision) {
        this.decision = decision;
    }

    public String getCvPath() {
        return cvPath;
    }

    public void setCvPath(String cvPath) {
        this.cvPath = cvPath;
    }

    public String getNomComplet() {
        return prenom + " " + nom;
    }
}
