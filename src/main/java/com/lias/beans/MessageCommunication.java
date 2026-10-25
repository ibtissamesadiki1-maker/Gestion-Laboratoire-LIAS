package com.lias.beans;

import java.io.Serializable;

/**
 * Entité représentant un message de communication interne (CDC §13).
 */
public class MessageCommunication implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String canalId;       // general, direction, team_dscc, team_msi, team_ia, event_casadata
    private String canalNom;
    private String auteurNom;
    private String auteurEmail;
    private String auteurRole;
    private String message;
    private String dateEnvoi;

    public MessageCommunication() {
        super();
    }

    public MessageCommunication(Long id, String canalId, String canalNom, String auteurNom, String auteurEmail, String auteurRole, String message, String dateEnvoi) {
        this.id = id;
        this.canalId = canalId;
        this.canalNom = canalNom;
        this.auteurNom = auteurNom;
        this.auteurEmail = auteurEmail;
        this.auteurRole = auteurRole;
        this.message = message;
        this.dateEnvoi = dateEnvoi;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getCanalId() {
        return canalId;
    }

    public void setCanalId(String canalId) {
        this.canalId = canalId;
    }

    public String getCanalNom() {
        return canalNom;
    }

    public void setCanalNom(String canalNom) {
        this.canalNom = canalNom;
    }

    public String getAuteurNom() {
        return auteurNom;
    }

    public void setAuteurNom(String auteurNom) {
        this.auteurNom = auteurNom;
    }

    public String getAuteurEmail() {
        return auteurEmail;
    }

    public void setAuteurEmail(String auteurEmail) {
        this.auteurEmail = auteurEmail;
    }

    public String getAuteurRole() {
        return auteurRole;
    }

    public void setAuteurRole(String auteurRole) {
        this.auteurRole = auteurRole;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getDateEnvoi() {
        return dateEnvoi;
    }

    public void setDateEnvoi(String dateEnvoi) {
        this.dateEnvoi = dateEnvoi;
    }
}
