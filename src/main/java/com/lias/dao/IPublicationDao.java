package com.lias.dao;

import java.util.List;
import com.lias.beans.Publication;

public interface IPublicationDao {
    List<Publication> findAll();
    List<Publication> findByYear(int year);
    List<Publication> findByTeam(String team);
    List<Publication> findByAuthor(String author);
    List<Publication> searchAndSort(String team, Integer year, String author, String sortBy);
    boolean save(Publication pub);
}
