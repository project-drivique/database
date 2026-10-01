CREATE INDEX idx_vehicle_images_veh ON fleet.vehicle_images (vehicle_id);
CREATE UNIQUE INDEX uq_vehicle_images_primary ON fleet.vehicle_images (vehicle_id) WHERE is_primary;
CREATE INDEX idx_vehicle_documents_veh ON fleet.vehicle_documents (vehicle_id);
CREATE UNIQUE INDEX uq_vehicle_documents_active_type ON fleet.vehicle_documents (vehicle_id, document_type) WHERE is_active;
CREATE INDEX idx_vehicle_documents_expiration ON fleet.vehicle_documents (expires_at) WHERE is_active AND expires_at IS NOT NULL;
