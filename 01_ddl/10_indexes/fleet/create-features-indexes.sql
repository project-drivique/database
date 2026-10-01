CREATE INDEX idx_vehicle_features_feat ON fleet.vehicle_features (feature_id);
CREATE INDEX idx_user_favorite_vehicles_veh ON fleet.user_favorite_vehicles (vehicle_id);
CREATE INDEX idx_user_favorite_vehicles_user ON fleet.user_favorite_vehicles (user_id);
