package com.lias.beans;

import java.io.Serializable;

/**
 * JavaBean représentant une notification institutionnelle (CDC §19).
 */
public class NotificationLabo implements Serializable {
    private static final long serialVersionUID = 1L;

    private Integer id;
    private String kind;      // "adhesion", "publication", "event", "document", "meeting", "materiel", "rapport", "convention"
    private String whenText;  // "il y a 12 min", "il y a 1 h", "aujourd'hui", "hier"
    private boolean read;
    private String who;       // "Imane Benkirane", "A. Saidi", "Système"
    private String body;
    private String actionLabel; // "Examiner →", "Valider →", "Voir →", "Ouvrir →"
    private String targetUrl;   // "/adhesions", "/publications", "/evenements", etc.

    public NotificationLabo() {
    }

    public NotificationLabo(Integer id, String kind, String whenText, boolean read, String who, String body, String actionLabel, String targetUrl) {
        this.id = id;
        this.kind = kind;
        this.whenText = whenText;
        this.read = read;
        this.who = who;
        this.body = body;
        this.actionLabel = actionLabel;
        this.targetUrl = targetUrl;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getKind() {
        return kind;
    }

    public void setKind(String kind) {
        this.kind = kind;
    }

    public String getWhenText() {
        return whenText;
    }

    public void setWhenText(String whenText) {
        this.whenText = whenText;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public String getWho() {
        return who;
    }

    public void setWho(String who) {
        this.who = who;
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }

    public String getActionLabel() {
        return actionLabel;
    }

    public void setActionLabel(String actionLabel) {
        this.actionLabel = actionLabel;
    }

    public String getTargetUrl() {
        return targetUrl;
    }

    public void setTargetUrl(String targetUrl) {
        this.targetUrl = targetUrl;
    }
}
