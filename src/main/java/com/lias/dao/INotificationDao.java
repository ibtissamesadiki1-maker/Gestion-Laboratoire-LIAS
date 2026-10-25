package com.lias.dao;

import java.util.List;
import com.lias.beans.NotificationLabo;

/**
 * Interface DAO pour les notifications institutionnelles (CDC §19).
 * Catégories statutaires :
 * • Événements
 * • Validation demandes
 * • Ajouts de documents
 */
public interface INotificationDao {
    List<NotificationLabo> findAll();
    List<NotificationLabo> findByKind(String kind);
    List<NotificationLabo> findByCategory(String category);
    List<NotificationLabo> findUnread();
    boolean markAsRead(int id);
    boolean markAllAsRead();
    boolean save(NotificationLabo notif);
    boolean delete(int id);
}
