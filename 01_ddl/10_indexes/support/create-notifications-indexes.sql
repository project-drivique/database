CREATE INDEX idx_notifications_user_unread ON support.notifications (user_id, is_read);
CREATE INDEX idx_notifications_user ON support.notifications (user_id);
CREATE INDEX idx_notifications_type ON support.notifications (type);
CREATE INDEX idx_notifications_channel ON support.notifications (channel);
CREATE INDEX idx_notifications_created_at ON support.notifications (created_at);
