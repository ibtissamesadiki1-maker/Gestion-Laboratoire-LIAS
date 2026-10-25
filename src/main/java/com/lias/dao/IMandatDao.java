package com.lias.dao;

import java.util.List;
import com.lias.beans.Mandat;

public interface IMandatDao {
    List<Mandat> findAll();
    Mandat findActive();
    Mandat findById(Long id);
    boolean save(Mandat mandat);
}
