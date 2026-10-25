package com.lias.dao;

import java.util.List;
import com.lias.beans.ReunionPV;

/**
 * Interface d'accès aux données des Procès-Verbaux de Réunions (CDC §17).
 */
public interface IPVDao {
    List<ReunionPV> findAll();
    ReunionPV findById(Long id);
    List<ReunionPV> findByType(String type);
    List<ReunionPV> findByStatut(String statut);
    List<ReunionPV> search(String query);
    boolean save(ReunionPV pv);
    boolean update(ReunionPV pv);
    boolean updatePVFile(Long id, String cheminFichier, String statut);
    boolean delete(Long id);
}
