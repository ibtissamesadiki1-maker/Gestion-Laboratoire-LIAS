package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant un utilisateur du système LIAS.
 * Conforme à l'architecture standard JEE / JavaBeans.
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String password;
    private String role; // directeur, permanent, doctorant, admin, visiteur
    private boolean actif;

    public User() {
        super();
    }

    public User(Long id, String nom, String prenom, String email, String password, String role, boolean actif) {
        this.id = id;
        this.nom = nom;
        this.prenom = prenom;
        this.email = email;
        this.password = password;
        this.role = role;
        this.actif = actif;
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isActif() {
        return actif;
    }

    public void setActif(boolean actif) {
        this.actif = actif;
    }

    public String getNomComplet() {
        return (prenom != null ? prenom : "") + " " + (nom != null ? nom : "");
    }

    @Override
    public String toString() {
        return "User [id=" + id + ", nom=" + nom + ", prenom=" + prenom + ", email=" + email + ", role=" + role + "]";
    }
}
