package com.lias.dao;

import java.util.List;
import com.lias.beans.Convention;
import com.lias.beans.ConventionActivite;

public interface IConventionDao {
    List<Convention> findAll();
    Convention findById(Long id);
    boolean save(Convention convention);

    // Activités associées aux conventions (CDC §16)
    List<ConventionActivite> findActivitesByConventionId(Long conventionId);
    List<ConventionActivite> findAllActivites();
    boolean saveActivite(ConventionActivite activite);
}
