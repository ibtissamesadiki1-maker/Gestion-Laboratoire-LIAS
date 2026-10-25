package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant un arrivage / lot de matériel scientifique (CDC §14).
 * Permet le suivi formel des livraisons et réceptions d'équipements au laboratoire LIAS.
 */
public class ArrivageMateriel implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String numeroBon;         // ex: BL-CNRST-2026-01
    private String designationLot;    // ex: Lot 2 Stations Calcul GPU NVIDIA RTX 4090
    private String fournisseurSource; // ex: Subvention CNRST IA / Faculté FSBM
    private int quantite;             // ex: 2
    private String dateArrivage;      // ex: 2026-01-04
    private String statutReception;   // CONFORME, EN_CONTROLE, RECEPTIONNE
    private String description;       // Remarques et caractéristiques techniques

    public ArrivageMateriel() {
        super();
    }

    public ArrivageMateriel(Long id, String numeroBon, String designationLot, String fournisseurSource, int quantite, String dateArrivage, String statutReception, String description) {
        this.id = id;
        this.numeroBon = numeroBon;
        this.designationLot = designationLot;
        this.fournisseurSource = fournisseurSource;
        this.quantite = quantite;
        this.dateArrivage = dateArrivage;
        this.statutReception = statutReception;
        this.description = description;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNumeroBon() {
        return numeroBon;
    }

    public void setNumeroBon(String numeroBon) {
        this.numeroBon = numeroBon;
    }

    public String getDesignationLot() {
        return designationLot;
    }

    public void setDesignationLot(String designationLot) {
        this.designationLot = designationLot;
    }

    public String getFournisseurSource() {
        return fournisseurSource;
    }

    public void setFournisseurSource(String fournisseurSource) {
        this.fournisseurSource = fournisseurSource;
    }

    public int getQuantite() {
        return quantite;
    }

    public void setQuantite(int quantite) {
        this.quantite = quantite;
    }

    public String getDateArrivage() {
        return dateArrivage;
    }

    public void setDateArrivage(String dateArrivage) {
        this.dateArrivage = dateArrivage;
    }

    public String getStatutReception() {
        return statutReception;
    }

    public void setStatutReception(String statutReception) {
        this.statutReception = statutReception;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
