package com.lias.dao;

import java.util.List;
import com.lias.beans.MessageCommunication;

public interface ICommunicationDao {
    List<MessageCommunication> findByCanal(String canalId);
    boolean save(MessageCommunication msg);
}
