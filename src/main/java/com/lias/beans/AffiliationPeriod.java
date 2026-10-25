package com.lias.beans;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Entité JavaBean représentant une période d'affiliation académique (Historisation).
 * Conforme au patron temporel non-destructif du cahier des charges LIAS.
 */
public class AffiliationPeriod implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String memberId;
    private LocalDate dateDebut;
    private LocalDate dateFin;
    private String roleHistorique;

    public AffiliationPeriod() {
    }

    public AffiliationPeriod(Long id, String memberId, LocalDate dateDebut, LocalDate dateFin, String roleHistorique) {
        this.id = id;
        this.memberId = memberId;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.roleHistorique = roleHistorique;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMemberId() {
        return memberId;
    }

    public void setMemberId(String memberId) {
        this.memberId = memberId;
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

    public String getRoleHistorique() {
        return roleHistorique;
    }

    public void setRoleHistorique(String roleHistorique) {
        this.roleHistorique = roleHistorique;
    }

    /**
     * Une période est considérée comme active et en cours si dateFin est nulle.
     */
    public boolean isEnCours() {
        return dateFin == null;
    }
}
