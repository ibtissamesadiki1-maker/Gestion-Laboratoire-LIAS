package com.lias.dao;

import java.util.List;
import com.lias.beans.ArrivageMateriel;
import com.lias.beans.DemandeAdhesion;
import com.lias.beans.Materiel;

public interface IDemandeDao {
    // Adhésions
    List<DemandeAdhesion> findAllAdhesions();
    DemandeAdhesion findAdhesionById(Long id);
    DemandeAdhesion findAdhesionByEmail(String email);
    boolean saveAdhesion(DemandeAdhesion adhesion);
    boolean updateDecisionAdhesion(Long id, String decision);

    // Matériel
    List<Materiel> findAllMateriels();
    boolean saveMateriel(Materiel mat);
    boolean updateStatutMateriel(Long id, String statut, String dateAttribution);

    // Suivi des Arrivages (CDC §14)
    List<ArrivageMateriel> findAllArrivages();
    boolean saveArrivage(ArrivageMateriel arrivage);
}

