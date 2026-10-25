package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant un chercheur / membre du laboratoire LIAS.
 * Conforme à la Section 3 du Cahier des Charges :
 * Informations complètes du profil :
 * - Photo
 * - Nom / Prénom
 * - Email
 * - Statut (permanent, associé, doctorant, retraité, ancien)
 * - Établissement d'origine
 * - Laboratoire d'origine
 * - Biographie
 * - Centres d'intérêt
 * - Équipe actuelle
 * - Grade
 */
public class Member implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;
    private String firstName;
    private String lastName;
    private String email;
    private String status; // permanent, doctorant, associe, retraité, ancien
    private String role;   // directeur, chef-equipe, membre, aucun
    private String team;   // IA, Big Data, NLP, Sécurité
    private String grade;  // Professeur, Maître de Conférences, Doctorant...
    private String photo;  // URL ou chemin vers la photo
    private String etablissementOrigine; // Établissement d'origine (CDC §3)
    private String laboratoireOrigine;   // Laboratoire d'origine (CDC §3)
    private String biographie;          // Biographie académique (CDC §3)
    private String centresInteret;      // Centres d'intérêt / Mots-clés (CDC §3)
    private String dateAffiliation;     // Clé métier temporelle (CDC §4.2)
    private String dateNaissance;       // Date de naissance confidentielle (CDC §4.2)
    private String dateEmbauche;        // Date d'embauche administrative (CDC §4.2)

    public Member() {
        super();
    }

    public Member(String id, String firstName, String lastName, String email, String status, String role, String team, String grade) {
        this(id, firstName, lastName, email, status, role, team, grade, null, "Faculté des Sciences Ben M'Sik", "LIAS", null, 
             "Intelligence Artificielle, Data Science", "2021-09-01", "1985-01-01", "2015-09-01");
    }

    public Member(String id, String firstName, String lastName, String email, String status, String role, String team, String grade,
                  String photo, String etablissementOrigine, String laboratoireOrigine, String biographie, String centresInteret, 
                  String dateAffiliation) {
        this(id, firstName, lastName, email, status, role, team, grade, photo, etablissementOrigine, laboratoireOrigine, biographie, 
             centresInteret, dateAffiliation, "1985-01-01", "2015-09-01");
    }

    public Member(String id, String firstName, String lastName, String email, String status, String role, String team, String grade,
                  String photo, String etablissementOrigine, String laboratoireOrigine, String biographie, String centresInteret, 
                  String dateAffiliation, String dateNaissance, String dateEmbauche) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.status = status;
        this.role = role;
        this.team = team;
        this.grade = grade;
        this.photo = photo;
        this.etablissementOrigine = etablissementOrigine != null ? etablissementOrigine : "Faculté des Sciences Ben M'Sik";
        this.laboratoireOrigine = laboratoireOrigine != null ? laboratoireOrigine : "LIAS";
        this.biographie = biographie;
        this.centresInteret = centresInteret != null ? centresInteret : "Intelligence Artificielle, Big Data";
        this.dateAffiliation = dateAffiliation != null ? dateAffiliation : "2021-09-01";
        this.dateNaissance = dateNaissance != null ? dateNaissance : "1985-01-01";
        this.dateEmbauche = dateEmbauche != null ? dateEmbauche : "2015-09-01";
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    /**
     * Libellé officiel du rôle de gouvernance selon CDC §7 :
     * Types : Directeur, Vice-directeur, Chef d'équipe, Membre d'équipe
     */
    public String getRoleLibelle() {
        if (role == null || role.trim().isEmpty()) return "Membre d'équipe";
        String r = role.toLowerCase().replace("_", "-").trim();
        switch (r) {
            case "directeur":
                return "Directeur";
            case "vice-directeur":
            case "vicedirecteur":
                return "Vice-directeur";
            case "chef-equipe":
            case "chef_equipe":
                return "Chef d'équipe";
            case "membre":
            case "membre-equipe":
            case "membre_equipe":
                return "Membre d'équipe";
            case "aucun":
                return "Aucun rôle actif";
            default:
                return role;
        }
    }

    public String getRoleBadgeClass() {
        if (role == null) return "badge-muted";
        String r = role.toLowerCase().replace("_", "-").trim();
        switch (r) {
            case "directeur":
                return "badge-gold";
            case "vice-directeur":
            case "vicedirecteur":
                return "badge-accent";
            case "chef-equipe":
            case "chef_equipe":
                return "badge-navy";
            case "membre":
            case "membre-equipe":
                return "badge-muted";
            default:
                return "badge-muted";
        }
    }

    public String getTeam() {
        return team;
    }

    public void setTeam(String team) {
        this.team = team;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public String getEtablissementOrigine() {
        return etablissementOrigine;
    }

    public void setEtablissementOrigine(String etablissementOrigine) {
        this.etablissementOrigine = etablissementOrigine;
    }

    public String getLaboratoireOrigine() {
        return laboratoireOrigine;
    }

    public void setLaboratoireOrigine(String laboratoireOrigine) {
        this.laboratoireOrigine = laboratoireOrigine;
    }

    public String getBiographie() {
        return biographie;
    }

    public void setBiographie(String biographie) {
        this.biographie = biographie;
    }

    public String getCentresInteret() {
        return centresInteret;
    }

    public void setCentresInteret(String centresInteret) {
        this.centresInteret = centresInteret;
    }

    public String getDateAffiliation() {
        return dateAffiliation;
    }

    public void setDateAffiliation(String dateAffiliation) {
        this.dateAffiliation = dateAffiliation;
    }

    public String getDateNaissance() {
        return dateNaissance;
    }

    public void setDateNaissance(String dateNaissance) {
        this.dateNaissance = dateNaissance;
    }

    public String getDateEmbauche() {
        return dateEmbauche;
    }

    public void setDateEmbauche(String dateEmbauche) {
        this.dateEmbauche = dateEmbauche;
    }

    public String getFullName() {
        return (firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "");
    }

    // Alias francophones pour compatibilité totale avec les vues JSP
    public String getNom() {
        return lastName;
    }

    public void setNom(String nom) {
        this.lastName = nom;
    }

    public String getPrenom() {
        return firstName;
    }

    public void setPrenom(String prenom) {
        this.firstName = prenom;
    }

    public String getEquipe() {
        return team;
    }

    public void setEquipe(String equipe) {
        this.team = equipe;
    }

    public String getStatut() {
        return status;
    }

    public void setStatut(String statut) {
        this.status = statut;
    }

    public String getSpeciality() {
        return centresInteret != null ? centresInteret : grade;
    }

    public void setSpeciality(String speciality) {
        this.centresInteret = speciality;
    }
}
