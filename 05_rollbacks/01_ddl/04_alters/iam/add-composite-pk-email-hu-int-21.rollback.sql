-- ROLLBACK HU-INT-21: Revertir Primary Key compuesta de iam.users a PRIMARY KEY (id)
ALTER TABLE iam.users DROP CONSTRAINT IF EXISTS users_pkey CASCADE;
ALTER TABLE iam.users DROP CONSTRAINT IF EXISTS uq_users_id CASCADE;
ALTER TABLE iam.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);

-- Recrear las 33 claves foraneas apuntando a iam.users(id)
ALTER TABLE iam.user_profiles ADD CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE iam.user_roles ADD CONSTRAINT fk_user_roles_assigned_by FOREIGN KEY (assigned_by) REFERENCES iam.users(id) ON DELETE SET NULL;
ALTER TABLE iam.user_roles ADD CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE iam.verification_codes ADD CONSTRAINT fk_verification_codes_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE iam.user_preferences ADD CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE iam.user_sessions ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE iam.user_documents ADD CONSTRAINT fk_user_documents_reviewer FOREIGN KEY (reviewed_by) REFERENCES iam.users(id);
ALTER TABLE iam.user_documents ADD CONSTRAINT fk_user_documents_user FOREIGN KEY (user_id) REFERENCES iam.users(id);
ALTER TABLE iam.user_consents ADD CONSTRAINT fk_user_consents_user FOREIGN KEY (user_id) REFERENCES iam.users(id);
ALTER TABLE location.branch_users ADD CONSTRAINT fk_branch_users_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE fleet.vehicle_documents ADD CONSTRAINT fk_vehicle_documents_verified_by FOREIGN KEY (verified_by) REFERENCES iam.users(id) ON DELETE SET NULL;
ALTER TABLE fleet.user_favorite_vehicles ADD CONSTRAINT fk_user_favorite_vehicles_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE fleet.vehicle_maintenances ADD CONSTRAINT fk_vehicle_maintenances_created_by FOREIGN KEY (created_by) REFERENCES iam.users(id) ON DELETE SET NULL;
ALTER TABLE catalog.user_coupon_usages ADD CONSTRAINT fk_user_coupon_usages_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE rental.reservations ADD CONSTRAINT fk_reservations_customer FOREIGN KEY (customer_id) REFERENCES iam.users(id);
ALTER TABLE rental.rental_extension_requests ADD CONSTRAINT fk_rental_extension_requests_reviewer FOREIGN KEY (reviewed_by) REFERENCES iam.users(id) ON DELETE SET NULL;
ALTER TABLE contract.rental_contracts ADD CONSTRAINT fk_rental_contracts_customer FOREIGN KEY (customer_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE contract.vehicle_inspections ADD CONSTRAINT fk_vehicle_inspections_inspector FOREIGN KEY (inspector_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE billing.payments ADD CONSTRAINT fk_payments_confirmed_by FOREIGN KEY (confirmed_by_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE billing.user_saved_payment_methods ADD CONSTRAINT fk_user_saved_payment_methods_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE rental.vehicle_ratings ADD CONSTRAINT fk_vehicle_ratings_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE rental.branch_reviews ADD CONSTRAINT fk_branch_reviews_replied_by FOREIGN KEY (replied_by) REFERENCES iam.users(id);
ALTER TABLE rental.branch_reviews ADD CONSTRAINT fk_branch_reviews_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE support.incident_reports ADD CONSTRAINT fk_incident_reports_assigned_to FOREIGN KEY (assigned_to_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE support.incident_reports ADD CONSTRAINT fk_incident_reports_reported_by FOREIGN KEY (reported_by_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE support.incident_responses ADD CONSTRAINT fk_incident_responses_author FOREIGN KEY (author_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE support.notifications ADD CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE audit.generated_reports ADD CONSTRAINT fk_generated_reports_generated_by FOREIGN KEY (generated_by) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE audit.audit_logs ADD CONSTRAINT fk_audit_logs_actor FOREIGN KEY (actor_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE iam.user_social_accounts ADD CONSTRAINT fk_user_social_accounts_user FOREIGN KEY (user_id) REFERENCES iam.users(id) ON DELETE CASCADE;
ALTER TABLE support.incident_attachments ADD CONSTRAINT fk_incident_attachments_user FOREIGN KEY (uploaded_by_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE support.incident_status_history ADD CONSTRAINT fk_incident_status_history_user FOREIGN KEY (changed_by_user_id) REFERENCES iam.users(id) ON DELETE RESTRICT;
ALTER TABLE iam.security_configuration_changes ADD CONSTRAINT security_configuration_changes_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES iam.users(id);
